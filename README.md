# Develop Helm

helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency build charts/operately
helm upgrade --install operately charts/operately -f test/operately/values.yaml --create-namespace -n operately
