# Develop Helm

helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency build charts/operately
helm upgrade --install operately charts/operately -f test/operately/values.yaml --create-namespace -n operately
kubectl rollout restart deployment operately-operately -n operately

helm uninstall operately -n operately
helm upgrade --install operately charts/operately -f test/operately/values_external_db.yaml --create-namespace -n operately
helm upgrade --install operately charts/operately -f test/operately/values_external_db_minio.yaml --create-namespace -n operately