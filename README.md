# OpnForm on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/opnform-1?utm_medium=integration&utm_source=button&utm_campaign=opnform)

Railway template for [OpnForm](https://github.com/OpnForm/OpnForm) **2.8.4**, the open-source form builder (a self-hosted Typeform / Google Forms alternative).

## What it deploys

| Service | Source | Purpose |
|---|---|---|
| `OpnForm` (public) | `opnform/` in this repo: `jhumanj/opnform-api:2.8.4` (pinned by digest) plus Caddy 2.11.9 | Laravel API on PHP-FPM, the queue worker, the scheduler, and a Caddy front proxy on `PORT` that sends `/api/*` to Laravel and everything else to the client. Uploaded files and OAuth keys live on a volume at `/usr/share/nginx/html/storage`. |
| `opnform-client` (private) | `client/` in this repo: `jhumanj/opnform-client:2.8.4` (pinned by digest) | Nuxt front end (server-side rendering), reached over Railway's private network. |
| `Postgres` | Railway PostgreSQL | Forms, submissions, users. |
| `Redis` | Railway Redis | Cache, sessions and job queue. |

The worker and scheduler run in the `OpnForm` service (unlike upstream's Compose file, which uses separate containers) because a Railway volume attaches to one service only, and all three PHP processes need the same storage.

## Variables

| Service | Variable | Value |
|---|---|---|
| OpnForm | `APP_KEY` | Generated: `base64:` + 32 random bytes |
| OpnForm | `JWT_SECRET`, `FRONT_API_SECRET` | Generated secrets |
| OpnForm | `APP_URL`, `FRONT_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| OpnForm | `DB_*`, `REDIS_*` | References to the Postgres and Redis services |
| OpnForm | `CLIENT_UPSTREAM` | `http://${{opnform-client.RAILWAY_PRIVATE_DOMAIN}}:3000` |
| opnform-client | `NUXT_API_SECRET` | `${{OpnForm.FRONT_API_SECRET}}` |
| opnform-client | `NUXT_PUBLIC_APP_URL`, `NUXT_PUBLIC_API_BASE`, `NUXT_PRIVATE_API_BASE` | References to the OpnForm service's public and private domains |

Nothing needs to be filled in at deploy time. Fixed settings (Postgres driver, Redis cache/queue/sessions, PHP limits, logging to stderr) are set in `opnform/Dockerfile`; override any of them with a service variable. Optional features such as SMTP (`MAIL_MAILER=smtp`, `MAIL_HOST`, ...), S3 storage, captcha or OpenAI keys are documented in the [OpnForm environment variable docs](https://docs.opnform.com/configuration/environment-variables).

**Custom domain:** if you add one, change `APP_URL` and `FRONT_URL` on `OpnForm` and `NUXT_PUBLIC_APP_URL` / `NUXT_PUBLIC_API_BASE` on `opnform-client` to the new origin.

## First start

Open the public URL. OpnForm redirects to a setup page where you create the admin account; after that, public sign-up is closed and you invite other users from the admin account. Free self-hosted instances allow 2 users (OpnForm's limit; an Enterprise license raises it).

## Updates

Each release of this repo pins new upstream image digests in the two Dockerfiles and gets a `CHANGELOG.md` entry. When a change is merged to `main`, Railway offers the update to everyone who deployed the template; read the changelog first. Database migrations run automatically when the `OpnForm` service starts.

## License

OpnForm is licensed under AGPL-3.0 (with an Enterprise directory under its own license); see the [upstream repo](https://github.com/OpnForm/OpnForm).
