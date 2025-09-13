# Operately Helm Chart

This chart deploys Operately to Kubernetes:
- Runs database migrations automatically.
- Supports either an external PostgreSQL or an in-cluster PostgreSQL (Bitnami)
- Supports persistent storage (e.g., Longhorn) with local storage and S3 (Minio)

## Introduction
## Prerequisites
## Installing the Chart
### All-In-One
This is example of all-in-one run
- No persistent storage
- Internal PostgreSQL
```yaml
replicaCount: 1

env:
  # This is strictly need modify in the end url like localhost or cluster
  operatelyHost: "localhost"
  urlScheme: "http"
  allowLoginWithEmail: "yes"

service:
  type: ClusterIP
  port: 4000

ingress:
  enabled: false

# No persistence
persistence:
  enabled: false

# No external database
externalPostgresql:
  enabled: false

# Use internal database
postgresql:
  enabled: true

  # No persistence internal database
  primary:
    persistence:
      enabled: false

secrets:
  # Generate a random with: openssl rand -hex 64
  secretKeyBase: "a3f1c5d7e9214b8c0f2e6a9db3c7e5f18b7a6c5d4e3f2a1908b7c6d5e4f3a2915e6f7a8b9c0d1e2f3a4b5c6d7e8f9012c3d4e5f60718293a4b5c6d7e8f90a1b2"

  # Generate with: openssl rand -base64 32
  blobTokenSecretKey: "pY0B2l1n2hQ0o7mC1kJc8vG1gYxq0WkqQ6g5qV3H9oY="

```
### With External PostgreSQL
Example for extrenal database
- No persistent storage

```yaml
replicaCount: 1

env:
  # This is strictly need modify in the end url like localhost or cluster
  operatelyHost: "localhost"
  urlScheme: "http"
  allowLoginWithEmail: "yes"

service:
  type: ClusterIP
  port: 4000

ingress:
  enabled: false

# No persistence (uses emptyDir for /media)
persistence:
  enabled: false

externalPostgresql:
  enabled: true
  databaseUrl: "ecto://user:password@postgresql.postgresql.svc.cluster.local:5432/operately"

postgresql:
  enabled: false

secrets:
  # Generate a random with: openssl rand -hex 64
  secretKeyBase: "a3f1c5d7e9214b8c0f2e6a9db3c7e5f18b7a6c5d4e3f2a1908b7c6d5e4f3a2915e6f7a8b9c0d1e2f3a4b5c6d7e8f9012c3d4e5f60718293a4b5c6d7e8f90a1b2"

  # Generate with: openssl rand -base64 32
  blobTokenSecretKey: "pY0B2l1n2hQ0o7mC1kJc8vG1gYxq0WkqQ6g5qV3H9oY="

```
### With External PostgreSQL and Minio
```yaml
replicaCount: 1

env:
  operatelyHost: "localhost"
  urlScheme: "http"
  allowLoginWithEmail: "yes"
  storageType: "s3"

extraEnv:
  ## TODO: Make it a sperate env
  - name: CERT_AUTO_RENEW
    value: "no"
  - name: CERT_DOMAIN
    value: "localhost"
  - name: CERT_EMAILS
    value: "admin@localhost"
  - name: CERT_DB_DIR
    value: "/media/certs"
  ## S3
  - name: OPERATELY_STORAGE_S3_HOST
    value: "minio.example.com" 
  - name: OPERATELY_STORAGE_S3_SCHEME
    value: "https"
  - name: OPERATELY_STORAGE_S3_BUCKET
    value: "operately-media"
  - name: OPERATELY_STORAGE_S3_REGION
    value: "minio"
  - name: OPERATELY_STORAGE_S3_ACCESS_KEY_ID
    value: "S3_ACCESS_KEY"       # for testing; use a Secret in prod
  - name: OPERATELY_STORAGE_S3_SECRET_ACCESS_KEY
    value: "S3_SECRET_ACCESS_KEY"       # for testing; use a Secret in prod

service:
  type: ClusterIP
  port: 4000

ingress:
  enabled: false

# No persistence (uses emptyDir for /media)
persistence:
  enabled: false

externalPostgresql:
  enabled: true
  databaseUrl: "ecto://operately_user:vaUEPza4hdfhs@postgresql.postgresql.svc.cluster.local:5432/operately"

postgresql:
  enabled: false

secrets:
  # Generate a random 64-char secret at render time for local usage
  secretKeyBase: "a3f1c5d7e9214b8c0f2e6a9db3c7e5f18b7a6c5d4e3f2a1908b7c6d5e4f3a2915e6f7a8b9c0d1e2f3a4b5c6d7e8f9012c3d4e5f60718293a4b5c6d7e8f90a1b2"
```
## Parameters