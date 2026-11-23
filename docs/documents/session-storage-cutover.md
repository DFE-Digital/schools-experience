# Session and registration storage cutover

Rails sessions (`browser_sessions`) and unfinished candidate registrations
(`candidate_registrations`) are stored in Postgres instead of Redis. Records
are never copied between stores on read; instead every write and delete updates
both stores together under one Postgres advisory lock per record, and
`SESSION_STORAGE` moves the application through three phases. Each phase is
safe to run alongside the one before it, so each step is an ordinary rolling
deploy and nobody is logged out and no unfinished registration is lost.

| Phase | Reads | Writes | Compatible with |
|-------|-------|--------|-----------------|
| `redis` (default) | Redis | Redis, plus a shadow copy in the database | pre-database code |
| `dual` | database | database and Redis | pre-database code and `redis` |
| `database` | database | database | `dual` |

Signed session cookies are only issued in `database`. Earlier phases keep the
existing unsigned cookie so older pods can still read it, and sign a cookie
only if the browser already sent a signed one. In `dual` and `database` an
unsigned cookie is accepted only for a row written before signing; the response
replaces it with a signed cookie and that row then refuses the unsigned value.

## Deployment sequence

1. Run the migrations (new tables only), then deploy with `SESSION_STORAGE`
   unset (`redis`). Behaviour is unchanged for users; the database fills with
   shadow copies.
2. Wait at least one day (the registration lifetime; sessions last three hours)
   after the last pre-database pod has gone, so every live record has a database
   copy. Then set `SESSION_STORAGE=dual` and roll.
3. Soak in `dual` for as long as needed. This is the safe rollback point: Redis
   is still current, so rolling back to `redis` or to pre-database code loses
   nothing.
4. When confident, set `SESSION_STORAGE=database` and roll. Redis is no longer
   written for sessions or registrations.
5. Once `expire_after` (three hours) has passed after step 4 is fully rolled
   out, remove the unsigned-cookie branches and `signed_cookie` column, and the
   `redis`/`dual` phases once rollback is no longer wanted.

## Rollback

* Any phase back to the previous one is a config change and rolling restart.
* `dual` or `redis` back to pre-database code is lossless.
* `database` back to `dual` is lossless. Do not go from `database` straight back
  to `redis` or pre-database code: Redis stopped receiving writes, so recent
  edits would be stale and sessions revoked since would reappear (up to three
  hours for sessions, one day for registrations).

In `dual`, a session write whose Redis mirror fails is rejected (and the
database write rolled back) rather than leaving a database-only copy. Redis
errors on session *deletes* are swallowed by the cache store, so if Redis was
unhealthy during `dual`, wait out the session lifetime before rolling back to
`redis`.

## What this does not cover

Live database capacity and connection pool size have not been verified; confirm
them with Infrastructure before step 1 (sessions add queries on each request's
existing connection and take a short advisory lock on writes).
