# Deploying to Render

The repo ships `render.yaml`: one **Render Free** Docker web service in the `ohio` region (AWS us-east-2),
with an external **Neon Free** Postgres database in the same AWS region. Cache, Queue, and Cable share that database.
This default intentionally lets the web service sleep. Expect cold starts and paused background work while it
sleeps; choose always-on hosting before promising timely job delivery or continuous availability.

The Blueprint explicitly sets `plan: free`. When adopting it for an existing deployment, retain that service's
chosen plan before syncing: the Blueprint can change the existing service's plan. Omitting `plan` preserves an
existing service's plan but selects a paid plan for a new service. To upgrade, change `plan` in `render.yaml`
and sync: the next sync overwrites a conflicting dashboard-only change. See [Render's plan rules][render-plan]
and [Blueprint sync controls][render-sync].

Ohio is the default because the initial apps and maintainers are centered around Chicago. If an application's
users are elsewhere, choose a nearer supported region before first deploy and change Render and Neon together.

## Before inviting real users

Complete the bracketed details in `/privacy` and `/terms`: the operator's legal name, contact information, effective
date, hosting and other providers, and retention periods. Verify that the policies describe the application's actual
data collection, purposes, transfers, retention, and rights processes. Fill unknowns from real operating decisions;
do not invent practices or assume a jurisdiction. Add applicable law or a forum only when the owner has chosen it.
Keep the visible draft notice while details or statements remain unfinished.

Retain the policy text's source, license, and adaptation attribution when revising it. That attribution concerns the
covered policy text; it does not change the licenses of application code, branding, or third-party assets.

## First deploy

1. Push the repository to GitHub and let its CI checks pass.
2. In Neon, create a **Free** project using **PostgreSQL 18 or newer** in **AWS us-east-2 (Ohio)**; generated tables use
   `uuidv7()`. Copy the direct connection string with
   connection pooling off (no `-pooler` in the hostname). `db:prepare` uses migration advisory locks and the
   application installs session-level query timeouts, both of which require a direct/session connection.
3. In Render, choose **New → Blueprint**, select the repository, and paste the Neon string as `DATABASE_URL`.
   It is the only prompted value; Render generates `SECRET_KEY_BASE`, and observability remains dormant until
   its optional keys are added later. Confirm that the proposed web service plan is **Free**. The Blueprint
   provisions no Render database.
4. Wait for the GitHub checks and deploy. Confirm the intended commit is live in Render's Deploys page, then check
   the application's behavior and that `https://<your-app>.onrender.com/ready` returns 200.

Render regions are immutable after service creation. Recreate, rather than reconfigure, a service created in
the wrong region. Keep the database and service colocated: even a tiny app pays cross-region latency on every
Solid Cache, Queue, Cable, and domain query.

## Code deploys and Blueprint sync

`autoDeployTrigger: checksPass` makes automatic **code deploys** wait for CI. Blueprint configuration sync is a
separate path: do not assume that setting gates plan or environment changes. To coordinate those changes, set
**Auto Sync → No** on the Blueprint's Settings page, then use **Manual Sync** when ready. See Render's
[CI integration][render-ci] and [Blueprint sync controls][render-sync].

After a deploy, verify the intended commit's successful, live deployment in Render and exercise the affected
behavior. A 200 from `/ready` proves that the responding instance can reach its database; it does not identify the
commit serving traffic. Render can keep serving the previous healthy deployment when the new one fails its
[health checks][render-health].

## The single-instance 512 MB runtime profile

The Blueprint settings are a coupled profile for one 512 MB Render Free instance:

- `WEB_CONCURRENCY=0` keeps Puma in single mode. Render otherwise supplies `1`, which starts a cluster master
  plus worker and wastes memory.
- `RAILS_MAX_THREADS=3` bounds request concurrency.
- `SOLID_QUEUE_IN_PUMA=true` runs Solid Queue in async/thread mode in the Puma process. Fork mode is a better
  isolation boundary when memory allows, but exceeds the free instance's budget.
- `DB_POOL=8` leaves connection headroom for three request threads plus Queue execution, polling, and heartbeat
  work.
- jemalloc is preloaded and configured in the Docker image to return dirty pages promptly and limit arenas.
- `db:prepare` runs in the web entrypoint because Render Free has no coordinated pre-deploy command.

Size processes, threads, and database pools from measurements as the application grows. Moving to a paid plan
does not itself require a separate job worker. Multiple instances or a separate worker need their own migration,
connection-budget, and deployment coordination.

The baseline does not install a request-wide timeout. Database statement and lock timeouts remain configured in
`config/database.yml`; choose additional operation timeouts and any request backstop for the application's workload
and deployment topology. Without a request backstop, a runaway request can continue occupying a Puma thread.

The memory profile came from deployed student apps, not an estimate: the incident sequence is recorded in
`appdev-projects/rails-8-template` [PR #22](https://github.com/appdev-projects/rails-8-template/pull/22)
(Puma cluster OOM), [PR #23](https://github.com/appdev-projects/rails-8-template/pull/23) (Solid Queue fork versus
async), and [PR #27](https://github.com/appdev-projects/rails-8-template/pull/27) (region colocation). Render's
[environment-variable documentation](https://render.com/docs/environment-variables) explains its injected Puma
concurrency, and its [Blueprint specification](https://render.com/docs/blueprint-spec) defines the plan, region,
and checks-passed deployment behavior. Render's
[instance-type reference](https://render.com/docs/compute-plans) records the current memory and CPU budgets.

If you later add per-IP endpoint limits, verify client identity in the deployed proxy topology.
Rails' [`rate_limit`](https://api.rubyonrails.org/v8.1.3/classes/ActionController/RateLimiting/ClassMethods.html)
defaults to `request.remote_ip`. [Render forwards public requests through Cloudflare and load
balancers](https://render.com/articles/how-render-handles-ddos-attacks#reading-the-true-client-ip), so choose an
appropriate `by:` key using the provider's verified header and trust contract.

## Secrets and encrypted credentials

`render.yaml` generates a persistent `SECRET_KEY_BASE`. It signs cookies, sessions, and CSRF tokens and does
not decrypt Rails credentials, so no master key is needed for the baseline.

The Foundation deliberately ships no `config/credentials.yml.enc` or shared master key. If the application
later adopts encrypted credentials, run `bin/rails credentials:edit` to create a fresh pair for that application,
commit only the encrypted file, and add the generated `config/master.key` value to Render as
`RAILS_MASTER_KEY`. Never commit the key. You may then opt into `config.require_master_key = true`.

## Environment keys

`.env.example` documents application settings and optional local overrides. Production does not load dotenv files:
supply deployment values through Render. Its Blueprint prompts for `DATABASE_URL`, generates `SECRET_KEY_BASE`,
and configures the runtime values marked below. An absent or partial local `.env` does not indicate missing
production configuration; Rails and the relevant integrations validate the values they actually use.

| Key | Required? | What it does |
|---|---|---|
| `DATABASE_URL` | you provide | Direct Neon connection; application and all three Solid adapters share it |
| `SECRET_KEY_BASE` | generated by Render | Cookie/session/CSRF signing |
| `WEB_CONCURRENCY` | Blueprint (`0`) | Puma single mode for the 512 MB profile |
| `RAILS_MAX_THREADS` | Blueprint (`3`) | Puma request threads |
| `DB_POOL` | Blueprint (`8`) | Shared Active Record connection ceiling |
| `SOLID_QUEUE_IN_PUMA` | Blueprint (`true`) | Enables in-process Solid Queue async mode; only the literal `true` enables it |
| `JOB_CONCURRENCY` | optional (`1`) | Queue worker process count for a fork-mode supervisor; the Blueprint uses async mode |
| `SOLID_CACHE_MAX_SIZE_MB` | optional (`64`) | Disposable cache budget inside the shared database |
| `SOLID_QUEUE_POLL_INTERVAL` | optional (`5`) | Seconds between Queue worker polls; also the worst-case job pickup latency |
| `SOLID_QUEUE_DISPATCH_INTERVAL` | optional (`5`) | Seconds between Queue dispatcher polls for due scheduled jobs |
| `SOLID_CABLE_POLL_INTERVAL` | optional (`1`) | Seconds between Cable listener polls; also the worst-case broadcast delivery delay |
| `ROLLBAR_ACCESS_TOKEN` | optional | Activates production error reporting; absent is silent and dormant |
| `ROLLBAR_ENV` | optional (Rails environment) | Overrides the Rollbar environment label |
| `SKYLIGHT_AUTHENTICATION` | optional | Activates production APM; absent is silent and dormant |
| `RAILS_LOG_LEVEL` | Blueprint (`info`) | Production log level |

Foundation remains production-domain-agnostic: it does not configure production Host Authorization or a canonical
host. A generic baseline does not know which public domains an application should serve. Before mapping a public
domain, configure the application's coordinated Render subdomain setting, host allowlist, and any canonical redirect.
Keep probes reaching their endpoints: Render uses a verified custom domain or the `onrender.com` host for `/ready`;
Docker probes `/up` on `localhost`. Host rules can block them, and redirects can count as healthy without executing
the intended check. Verify a direct 200 from each endpoint after changing domain policy. See [Render health checks][render-health].
The exact GitHub Codespaces host admitted in development is a separate preview rule.

## Health, sleeping, and background work

- `/up` is process liveness and intentionally does not touch the database. Docker uses it to decide whether the
  container booted.
- `/ready` performs a real database round-trip. Render uses it to decide whether the application can serve traffic.
- Neither route proves that a time-sensitive job has completed. Add a Queue heartbeat/dead-job alert before
  making delivery promises for push, scheduled email, or recurring work.

[Render Free][render-free] sleeps after 15 minutes without inbound traffic. Its in-process Queue stops with the
web service. Enqueued jobs wait until it wakes, including jobs scheduled with `set(wait_until:)`. Recurring tasks
due during sleep are skipped, not caught up. Do not add periodic external keep-alive or uptime requests to this
let-sleep setup: they can keep the service and database active.

If this web service is the database's only active client, stopping its polling should let an idle Neon Free compute
[scale to zero][neon-sleep]. Other clients or ongoing queries can prevent that. This is the expected sequence from
the providers' documentation, not a measured suspension guarantee for this application.

### Queue and Cable polling is metered bandwidth

Solid Queue uses database polling, so an idle worker and dispatcher still generate queries. With this profile's
external Neon database, outgoing query traffic counts toward Render's outbound bandwidth allowance. Charges depend
on traffic and the workspace allowance; these intervals do not measure a bill.
[Render's bandwidth rules](https://render.com/docs/outbound-bandwidth) exempt private traffic between Render services
in the same region. An external database in the same region does not receive that exemption merely because it is
nearby.

Production Queue worker and dispatcher defaults are both 5 seconds. Longer intervals reduce idle query traffic at
the cost of pickup latency: polling can add about 5 seconds for an immediate job and 10 seconds for a scheduled one,
before any execution backlog. Development and test keep the responsive stock intervals against a local database.
Tune `SOLID_QUEUE_POLL_INTERVAL` and `SOLID_QUEUE_DISPATCH_INTERVAL` for the application's latency and traffic needs.

Solid Cable's production default is 1 second. Its listener starts on subscription, so an application that adds
`turbo_stream_from` begins polling even without new broadcasts. Tune `SOLID_CABLE_POLL_INTERVAL` when interactive
channels need faster delivery, accounting for database traffic and the actual network path.

`spec/lib/runtime_configuration_spec.rb` retains a conservative 1-second floor for these three built-in production
defaults. The tests clear environment overrides and allow any default at or above that floor. They guard this
application's chosen idle-traffic policy; they do not measure billing or establish a universal safe interval.
Runtime overrides remain available. When deliberately choosing faster defaults, update the relevant guard with
that policy decision and its latency/traffic rationale.

The container filesystem is ephemeral. If the application accepts durable uploads, configure external object
storage; never place durable user files on the production `:local` service.

Neon's free storage is shared by application rows and Solid Cache/Queue/Cable. The baseline caps disposable
cache data at 64MB; monitor finished jobs, cable retention, and storage before approaching the provider limit.
Queue polling also keeps Neon compute active while the web service runs. Neon Free caps monthly compute and
transfer; exhausting either allowance suspends the database until the next billing period or an upgrade. Check
[Neon's current allowances][neon-plans] as usage grows.

## Email

The baseline sends no mail. If the application needs email, configure Action Mailer and its provider, set a real
application host, add delivery monitoring, and complete an SPF/DKIM/DMARC launch checklist.

[render-plan]: https://render.com/docs/blueprint-spec#plan
[render-ci]: https://render.com/docs/deploys#integrating-with-ci
[render-sync]: https://render.com/docs/infrastructure-as-code#disabling-automatic-sync
[render-health]: https://render.com/docs/health-checks
[render-free]: https://render.com/docs/free
[neon-sleep]: https://neon.com/docs/introduction/scale-to-zero
[neon-plans]: https://neon.com/docs/introduction/plans
