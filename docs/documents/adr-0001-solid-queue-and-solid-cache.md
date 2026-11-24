---
title: "ADR 0001: Replace Redis with Solid Queue and Solid Cache"
nav_order: 30
layout: page
---

# ADR 0001: Replace Redis and Sidekiq with Solid Queue and Solid Cache

- **Status:** Accepted (documentation only; no runtime change is made by this ADR)
- **Scope:** Background jobs, cache data, candidate registration data, login sessions

## Context

Redis currently does these jobs for the service:

- **Background jobs:** Sidekiq runs jobs, scheduled jobs, retries and cron tasks (`config/schedule.yml`). Sidekiq Web is exposed in lower environments only.
- **Cache:** `config.cache_store` uses `:redis_cache_store`.
- **Login sessions:** `config.session_store :cache_store` keeps Rails sessions in the cache, with a 3 hour TTL in production.
- **Unfinished candidate registrations:** these are not in the Rails session. `Candidates::Registrations::RegistrationStore` writes them directly to Redis (the `REDIS` connection pool), under a random UUID key, and they expire after one day.
- **External API responses:** production uses a Redis cache store with the `GIT-API-HTTP` namespace.
- **Rate limiting:** Rack::Attack has no store configured, so its throttle counters and Fail2Ban bans use `Rails.cache` (Redis today). It fails open on transient Redis errors.
- **Monitoring:** `Cron::HeartBeatJob` runs every minute and feeds the `sidekiq_heart_beat` metric.

We want fewer moving parts. The primary Postgres/PostGIS database is already operated and backed up.

## Decision

1. Replace Sidekiq with **Solid Queue** and the Redis cache with **Solid Cache**, on the existing primary database. We will not add separate queue or cache databases.
2. Store **unfinished candidate registration data** in its own table, and **login sessions** in a different table. The two tables are not combined.
   - Model each record and its lifecycle on the Rails authentication generator's server-side session record, with a signed cookie that only references the record.
   - Adapt it to the existing identity providers, anonymous registrations, UUID/confirmation links and background-job contracts. We will not replace the authentication providers or generate a new login system.
   - Keep the registration one-day expiry and deletion on completion. Keep existing session lifetimes. The generator's permanent-cookie default must not extend expiry.
   - The login record does not replace every use of the Rails session hash. Compatibility must be checked before runtime work.
3. Keep production **external API responses** in Solid Cache, with the same expiry and `GIT-API-HTTP` namespace.
4. **Retries:** keep or add retries with timing as close as practical to today's effective behaviour. Sentry must be told after the last retry fails. We do not prescribe a blanket ten attempts over four hours.
   - Current source: `ApplicationJob` allows up to three attempts (`attempts: 3`, so two retries) for `StandardError` with `polynomially_longer` waits. `Notify::BaseJob` allows up to seven attempts for its retryable error, waiting 1 minute, 10 minutes, 1 hour, 2 hours, then 4 hours between attempts. `attempts` counts total attempts, not retries. Sidekiq's own retries are separate and add to this.
   - The full effective schedule and the direct Sentry capture paths are still to be mapped.
5. **Mission Control** (jobs dashboard) is available in lower environments only, like Sidekiq Web today. It is not mounted in production. Keep current development access and basic authentication elsewhere. Production operations use a console and a runbook.
6. **Worker health:** follow the Publish approach of checking recent `SolidQueue::Process` heartbeats for the Worker, Dispatcher and Scheduler (when recurring tasks are enabled), instead of an every-minute heartbeat job. Retire `Cron::HeartBeatJob` and the `sidekiq_heart_beat` metric. Remove the old alert together with Technical Infrastructure. Probe wiring is decided with them; a worker failure must not automatically remove web traffic. References: Publish [healthchecks](https://github.com/DFE-Digital/publish-teacher-training/blob/cd9d6796cfc9e8ae7fe717578ef6bd08480adacc/guides/healthchecks.md) and [recurring cutover](https://github.com/DFE-Digital/publish-teacher-training/blob/cd9d6796cfc9e8ae7fe717578ef6bd08480adacc/guides/solid-queue-recurring-cutover.md).
7. **No database scaling now.** Before runtime work, check database capacity and the effective connection pool per process with Technical Infrastructure, including Sidekiq and Solid Queue running together. A capacity problem is escalated, not fixed by assuming a scale-up.

We will not add a cache dashboard, and we will not make UNLOGGED tables mandatory.

## Rationale and consequences

- One less service to run, patch and monitor; the database is already backed up.
- Database load, connections and table size grow. Queue and cache traffic compete with application queries until capacity is checked.
- Jobs, sessions and cache entries move into backups and exports, so privacy matters: protect personal data in job arguments, logs, dashboards and exports, and redact job arguments in logs.
- Expiry must be enforced by the application on read, and expired registrations, sessions and cache entries must be deleted periodically.
- Rack::Attack will use Solid Cache through `Rails.cache`, with no separate store. Before runtime work, verify counter increments, expiry and Fail2Ban ban behaviour on Solid Cache, and keep the fail-open error handling. That handling currently rescues Redis error classes (`TRANSIENT_REDIS_ERRORS`) and needs adapting to database errors. If a needed feature is unsupported, report it rather than changing the architecture.

## Alternatives rejected

- Keep Redis and Sidekiq: keeps the extra service and its network reliability issues.
- Separate queue and cache databases: extra infrastructure; not needed now.
- Scale up the database now: not justified before measurement.
- Combine registrations and login sessions in one table: different lifecycles and privacy needs.
- Replace the authentication providers or build a new login system: out of scope.
- Copy the older blanket ten attempts / four-hour retry policy: does not match current effective behaviour.
- Mount Mission Control in production: it would be a new production exposure.

## Rollout

Each step is a separate change.

1. **This ADR and prechecks:** retry schedule, Sentry paths, session-hash compatibility, database capacity and pools, alert and probe wiring.
2. **Candidate registration table**, then **login session table**, separately. Preserve in-flight sessions and registrations during each switch.
3. **Solid Cache first**, including the external API cache.
4. **Solid Queue alongside Sidekiq**, with safe pilot jobs. Each schedule has one owner at a time, so recurring jobs never run twice.
5. **Global adapter and recurring cutover**, then health checks and Mission Control.
6. **Remove Redis and Sidekiq** only after the old queues, scheduled sets and retry sets have drained.

Rollback has limits: reverting code does not move new database records or jobs back to Redis. Plan each step with that in mind.

## Open checks (not yet performed)

- Effective retry schedule including Sidekiq retries, and direct Sentry capture paths.
- Rails session-hash uses that the login session table does not cover.
- Database capacity and per-process connection pools.
- Alert removal and probe wiring with Technical Infrastructure.
- Rack::Attack counter, expiry, ban and error-handling compatibility on Solid Cache.

## Related work

AQTS followed the same path: ADR #3313, cache #3312, queue coexistence #3316/#3329, adapter switch #3326, removal #3348. Apply lessons: production dispatcher #12106, reverted bulk cutover #12113, log redaction #12134, Redis removal #12168. These references have not been re-verified for this ADR.
