# Session and registration storage cutover

Rails sessions (`browser_sessions`) and unfinished candidate registrations
(`candidate_registrations`) are stored in Postgres instead of Redis. Records
are never copied between stores on read; instead every write and delete updates
both stores together under one Postgres advisory lock per record, and
`SESSION_STORAGE` moves the application through three phases. Each phase is
safe to run alongside the one before it, so each step is an ordinary rolling
deploy. Forward steps lose nothing. Rollback guarantees are narrower; see
"Rollback" below.

| Phase | Reads | Writes | Compatible with |
|-------|-------|--------|-----------------|
| `redis` (default) | Redis | Redis, plus a shadow copy in the database | pre-database code (until any signed cookie exists) |
| `dual` | database | database and Redis | `redis`; pre-database code (until any signed cookie exists) |
| `database` | database | database | `dual` |

Signed session cookies are only issued in `database`. Earlier phases keep the
existing unsigned cookie so older pods can still read it, and sign a cookie
only if the browser already sent a signed one. In `dual` and `database` an
unsigned cookie is accepted only for a row written before signing; the response
replaces it with a signed cookie and that row then refuses the unsigned value.
A row's `signed` flag only ever goes from false to true, and a response is
signed whenever the row is signed, even if the request that wrote it arrived
unsigned on a pod still in an earlier phase.

## Deployment sequence

1. Run the migrations (new tables only), then deploy with `SESSION_STORAGE`
   unset (`redis`). Behaviour is unchanged for users; the database fills with
   shadow copies.
2. Wait at least one day (the registration lifetime; sessions last three hours)
   after the last pre-database pod has gone, so every live record has a database
   copy. Then set `SESSION_STORAGE=dual` and roll.
3. Soak in `dual` for as long as needed. While no `database`-phase pod has ever
   run, this is a safe rollback point: Redis is still current.
4. When confident, set `SESSION_STORAGE=database` and roll. Redis is no longer
   written for sessions or registrations.
5. Once `expire_after` (three hours) has passed after step 4 is fully rolled
   out, remove the unsigned-cookie branches and `signed_cookie` column, and the
   `redis`/`dual` phases once rollback is no longer wanted.

## Rollback

Verified guarantees, and the boundaries where they stop:

* `dual` -> `redis` and `redis` -> `dual` (this code both sides) lose nothing.
* `dual` or `redis` -> pre-database code is lossless **only if `database` has
  never run** (no signed cookie has been issued). Pre-database code cannot parse
  signed cookies: once any exist, those users start a new anonymous session
  (logged out, in-progress forms lost) on pre-database code. Treat the first
  roll to `database` as the point after which pre-database code is not a
  supported rollback target.
* `database` -> `dual` is a **forward-safe stopgap, not a restore of Redis.**
  From then on writes are mirrored to Redis again, but only as each record is
  next written. Records created or changed in `database` are absent from or
  stale in Redis, and Redis copies of sessions logged out or registrations
  completed in `database` may still exist.
* Therefore do not go on to `redis` (or any Redis-reading code) after `database`
  has run. Doing so would drop users whose records were never re-mirrored
  (unfinished registrations are the main exposure) and could revive revoked
  sessions or completed registrations until their Redis TTLs lapse. No
  reconciliation task exists. If that rollback is ever required it is a user /
  Infrastructure decision about accepted impact, not something this change
  promises to make lossless.

In `dual`, a session write whose Redis mirror fails is rejected (and the
database write rolled back) rather than leaving a database-only copy. Redis
errors on session *deletes* are swallowed by the cache store, so if Redis was
unhealthy during `dual`, wait out the session lifetime before moving on.

## What this does not cover

Live database capacity and connection pool size have not been verified; confirm
them with Infrastructure before step 1 (sessions add queries on each request's
existing connection and take a short advisory lock on writes).
