Quick start

Install (default ClusterIP, port-forward):
helm install my-rw charts/rwmarkable
kubectl port-forward svc/my-rw-rwmarkable 8080:3000
Open http://127.0.0.1:8080
With Ingress:
helm install my-rw charts/rwmarkable --set ingress.enabled=true --set ingress.hosts[0].host=rwmarkable.example.com
Configure persistence classes and sizes if needed:
--set persistence.data.storageClassName=longhorn --set persistence.data.size=5Gi
Optional env/secrets examples

Set OIDC and HTTPS flags:
--set env.SSO_MODE=oidc --set env.OIDC_ISSUER=https://issuer --set env.OIDC_CLIENT_ID=my-client --set env.HTTPS=true
Provide OIDC client secret from existing secret:
--set secrets.name=my-oidc-secret --set-json 'extraSecretEnv=[{"name":"OIDC_CLIENT_SECRET","key":"OIDC_CLIENT_SECRET"}]'
Or have chart create the secret:
--set secrets.create=true --set secrets.data.OIDC_CLIENT_SECRET=supersecret
Notes

The chart name is lowercase rwmarkable to comply with Helm naming conventions.
If your cluster lacks a default StorageClass, set persistence.*.storageClassName explicitly.