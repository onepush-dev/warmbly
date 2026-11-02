# Warmbly on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/warmbly)

One-click Railway template for [Warmbly](https://github.com/warmbly/warmbly) (Apache-2.0), the open-source cold email and mailbox warmup platform. It runs upstream's published release images (v0.6.72), wired together with Railway Postgres, Redis and NATS. No inputs are needed at deploy time.

## Features

- Campaigns, sequences, a unified inbox, mailbox warmup and open/click tracking
- Connect mailboxes over SMTP/IMAP with nothing else set up. Gmail and Microsoft 365 OAuth are optional
- The owner account is created on first boot with a generated password, so there is no open setup link to race for
- Every secret is generated per deploy: AUTH_SECRET, KMS_LOCAL_MASTER_KEY, CREDENTIALS_ENCRYPTION_KEY, INTERNAL_API_TOKEN, NODE_BROKER_TOKEN and SECRET_KEY_BASE
- No cloud account required: NATS event bus, local KMS, filesystem blob storage on a volume and billing turned off

## Services

| Service | Image | Notes |
|---|---|---|
| Warmbly | `ghcr.io/onepush-dev/warmbly-core:0.6.72` | API (`/health`) + consumer + worker in one container. They share the `/data` volume (blobs + worker state), which Railway can't share across services |
| web | `ghcr.io/onepush-dev/warmbly-web:0.6.72` | Dashboard (public) |
| admin | `ghcr.io/onepush-dev/warmbly-admin:0.6.72` | Admin panel (public) |
| realtime | `ghcr.io/onepush-dev/warmbly-realtime:0.6.72` | Websocket fan-out (public, `wss://…/socket/websocket`) |
| tracking | `ghcr.io/onepush-dev/warmbly-tracking:0.6.72` | Open/click pixel host (public) |
| NATS | `nats:2.10.29-alpine` | JetStream event bus, volume `/data` |
| Postgres, Redis | Railway | Volumes |

Each image is `FROM ghcr.io/warmbly/warmbly/<service>:v0.6.72` with Railway defaults added: port 8080, dual-stack listeners and plain settings baked into ENV. They are built by `.github/workflows/publish-ghcr.yml`. The optional `forms` service and the docker-socket `updater` are left out.

## After deploy

1. Open the **web** service URL. Sign in with `WARMBLY_BOOTSTRAP_EMAIL` and `WARMBLY_ADMIN_PASSWORD`, which you'll find in the Warmbly service's Variables.
2. Before you invite anyone, set up SMTP for platform mail on the Warmbly service: `MAIL_TRANSPORT=smtp`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_SECURITY`, `EMAIL_ADDRESS`. Until then, platform mail is only written to the logs.
3. The admin panel needs a second factor. Enrol a passkey or TOTP under Settings → Security, then sign in to the **admin** URL.
4. Optional mailbox OAuth: add `BOX_GOOGLE_CLIENT_ID`, `BOX_GOOGLE_CLIENT_SECRET` and `BOX_GOOGLE_OAUTH_CONNECT=true` (also set `WARMBLY_GMAIL_OAUTH_CONNECT=true` on web), and/or `BOX_OUTLOOK_CLIENT_ID` and `BOX_OUTLOOK_CLIENT_SECRET`, on the Warmbly service. See the upstream configuration docs for the callback URLs.

## Notes

- **Back up `KMS_LOCAL_MASTER_KEY` and `CREDENTIALS_ENCRYPTION_KEY`.** If you lose either one, stored mailbox credentials can't be recovered. The template generates the KMS key as 64 hex characters, and the start script converts it to the base64 form Warmbly expects. A base64 value is used as-is.
- For real outreach, put tracking on a separate custom domain (see the upstream deliverability guide).
- To upgrade, bump `WARMBLY_TAG` in the workflow, let it build and publish, then redeploy every service on the same version.

Upstream docs: https://docs.warmbly.com
