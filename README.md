# Develop Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency operately ./charts/operately

helm install operately ./charts/operately
helm uninstall operately ./charts/operately