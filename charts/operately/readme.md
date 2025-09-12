# Operately Helm Chart

This chart deploys Operately (Elixir/Phoenix) to Kubernetes, runs database migrations automatically, and supports either an external PostgreSQL or an in-cluster PostgreSQL (Bitnami) with optional persistent storage (e.g., Longhorn).

## Features
- Production-ready Deployment, Service, optional Ingress
- Pre-install/upgrade Job to run `/opt/operately/bin/create_db` and `/opt/operately/bin/migrate`
- External DB or Bitnami PostgreSQL subchart
- Optional PVC for `/media` to persist application file data (default: storageClass `longhorn`)

## Quickstart (external DB)

1. Ensure you have a working PostgreSQL and construct a `DATABASE_URL` like:
   `ecto://USER:PASSWORD@HOST:5432/operately`

2. Create a secret with `DATABASE_URL` and `SECRET_KEY_BASE` or let the chart create it.

Example values (external DB + Longhorn persistence):

```yaml
image:
  repository: operately/operately
  tag: latest

env:
  operatelyHost: "operately.example.com"
  urlScheme: "https"
  port: 4000

persistence:
  enabled: true
  storageClassName: longhorn
  size: 20Gi

secrets:
  create: true
  secretKeyBase: "<output of: mix phx.gen.secret>"

db:
  external:
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
helm install operately charts/operately -f my-values.yaml
```

## Quickstart (in-cluster DB)

Enable Bitnami PostgreSQL and set credentials. The chart will compose `DATABASE_URL` for you and the migration job will wait for DB readiness.

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
  create: true
  secretKeyBase: "<output of: mix phx.gen.secret>"

env:
  operatelyHost: operately.example.com
```

## Persistence for `/media`
- Set `persistence.enabled: true` to create a PVC named `<release>-operately-media` mounted at `/media`.
- Default `storageClassName` is `longhorn` (change to match your cluster).
- Set `persistence.enabled: false` to use an `emptyDir` (ephemeral).

## Environment variables
The chart maps the following variables used by `app/config/runtime.exs`:
- `OPERATELY_HOST` (required), `OPERATELY_URL_SCHEME` (default: https), `PORT` (default: 4000)
- Feature flags like `ALLOW_LOGIN_WITH_EMAIL`, `ALLOW_SIGNUP_WITH_EMAIL`, etc.
- `DATABASE_URL` and `SECRET_KEY_BASE` are set via Secret.

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

