# Fiumed self-hosted deployment

This fork runs the upstream Fizzy application behind the existing Fiumed
infrastructure. Keep this file and `config/deploy.yml` aligned when updating
from upstream.

## Production invariants

- Host: `46.224.17.255`
- Public URL: `https://fizzy.fiumed.cloud`
- Proxy chain: external Caddy → host `localhost:3002` → the existing
  Kamal Proxy container on port 80 → Fizzy
- Registry: `localhost:5555`
- Persistent volume: `fizzy_fizzy-storage:/rails/storage`
- Account mode: single tenant (`MULTI_TENANT=false`)
- Active Storage: local, inside the persistent storage volume
- Jobs: Solid Queue runs in Puma
- SQLite: 10-second busy timeout plus WAL, normal synchronous mode, mmap, and
  cache pragmas from `config/database.sqlite.yml`

The volume name is existing production state. Do not rename it during an
upgrade.

The host's Kamal Proxy is an existing manually wired component. A normal app
deployment must reuse it. Do not run proxy boot/reboot or otherwise recreate
its host-port mapping as part of an application update.

## Fiumed-specific code

- `config/initializers/fiumed_pwa_controller_fix.rb` keeps the root service
  worker reachable before sign-in, which is required for PWA installation and
  updates.
- `config/initializers/fiumed_sqlite_busy_timeout.rb` reinforces the database
  busy timeout during application boot.
- `app/javascript/initializers/toolbar_tab_fix.js` preserves the established
  title-to-editor Tab behavior while keeping toolbar controls clickable.

Upstream now natively handles local Active Storage, single-tenant signup
blocking, SMTP configuration, mailer sender configuration, and Solid Queue.
Do not reintroduce the retired Fiumed initializers for those concerns.

## Environment mapping

The deployment uses upstream environment names:

- `BASE_URL`
- `MAILER_FROM_ADDRESS`
- `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`,
  `SMTP_PASSWORD`, `SMTP_AUTHENTICATION`
- `MULTI_TENANT`
- `SOLID_QUEUE_IN_PUMA`
- `ACTIVE_STORAGE_SERVICE`
- `DISABLE_SSL`

Secret values remain outside Git in Kamal's secret source.

## Upgrade gate

Before deploying an upstream upgrade:

1. Stop the Fizzy event watcher so automation does not act during migrations.
2. Confirm a current provider backup and take an application-consistent copy
   of `/rails/storage`.
3. Build and run the complete test suite from the exact candidate commit.
4. Review every pending database migration. Restoring only the old container
   image is not a valid rollback after a destructive migration.
5. Deploy, then verify `/up`, sign-in, boards, cards, comments, join links,
   email delivery, PWA service worker/manifest, and the event watcher.
6. Keep the old image plus the matching pre-migration storage copy until the
   verification window is complete.
