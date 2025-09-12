# Operately Helm Chart

This chart deploys Operately (Elixir/Phoenix) to Kubernetes, runs database migrations automatically, and supports either an external PostgreSQL or an in-cluster PostgreSQL (Bitnami) with optional persistent storage (e.g., Longhorn).

## Features
- Production-ready Deployment, Service, optional Ingress
- Pre-install/upgrade Job to run `/opt/operately/bin/create_db` and `/opt/operately/bin/migrate`
- External DB or Bitnami PostgreSQL subchart
- Optional PVC for `/media` to persist application file data (default: storageClass `longhorn`)

## Quickstart (external DB)

1. Ensure you have a working PostgreSQL and construct a `DATABASE_URL` like:
   `ecto://USER:PASSWORD@HOST:5432/operately` (or provide host/user/password under `externalPostgresql` and let the chart compose it).

2. Set `secrets.secretKeyBase` in your values. By default, the chart injects `SECRET_KEY_BASE` and `DATABASE_URL` directly from values (no Secret is created unless you opt in).

Example values (external DB + Longhorn persistence):

```yaml
service:
  type: ClusterIP
  port: 4000

persistence:
  enabled: true
  storageClassName: longhorn
  size: 20Gi

secrets:
  create: false
  secretKeyBase: "<output of: mix phx.gen.secret>"

externalPostgresql:
  enabled: true
  databaseUrl: "ecto://operately:supersecret@postgres.my.net:5432/operately"

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: operately.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts: [operately.example.com]
      secretName: operately-tls
```

Install:

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency build charts/operately
helm upgrade --install operately charts/operately -f charts/operately/my-values-local-no-pv.yaml --create-namespace -n operately
```

## Quickstart (in-cluster DB)

Enable Bitnami PostgreSQL and set credentials. The chart composes `DATABASE_URL` for you and the migration job waits for DB readiness.

```yaml
postgresql:
  enabled: true
  auth:
    username: operately
    password: supersecret
    database: operately
  primary:
    persistence:
      enabled: true
      storageClass: longhorn
      size: 10Gi

secrets:
  create: false
  secretKeyBase: "<output of: mix phx.gen.secret>"
```

## Persistence for `/media`
- Set `persistence.enabled: true` to create a PVC named `<release>-operately-media` mounted at `/media`.
- Default `storageClassName` is `longhorn` (change to match your cluster).
- Set `persistence.enabled: false` to use an `emptyDir` (ephemeral).

## Environment variables
The chart maps the following variables used by `app/config/runtime.exs`:
- `PORT` comes from `service.port`.
- `OPERATELY_URL_SCHEME` defaults to `http` if not set in values.
- `OPERATELY_HOST` is optional; omit for in-cluster-only usage.
- Feature flags like `ALLOW_LOGIN_WITH_EMAIL`, `ALLOW_SIGNUP_WITH_EMAIL`, etc.
- `DATABASE_URL` and `SECRET_KEY_BASE` are set directly from values by default.
  - To use a pre-existing Secret, set `secrets.name` and reference keys via `extraSecretEnv`.

To add more:
- Non-secret: `values.yaml` -> `extraEnv`
- Secret-backed: create/add keys to the chosen secret and reference via `extraSecretEnv`

## Notes
- The container’s default command runs `bin/server` which sets `PHX_SERVER=true`.
- Health probes are simple HTTP `GET /` on port 4000; adjust if you expose a dedicated health path.
- Ensure network access from pods to your external DB if using the external option.

## Uninstall
```sh
helm uninstall operately
```
