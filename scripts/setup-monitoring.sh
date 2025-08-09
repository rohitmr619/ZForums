#!/bin/bash
set -e

echo "🔧 Setting up Prometheus and Grafana monitoring..."

# Create namespace
sudo kubectl create namespace monitoring --dry-run=client -o yaml | sudo kubectl apply -f -

# Add prometheus community helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
KUBECONFIG=/etc/rancher/k3s/k3s.yaml sudo -E helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --values monitoring/prometheus-values.yaml \
    --wait --timeout 600s

echo "✅ Monitoring stack deployed!"
echo ""
echo "🎯 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
echo "   User: admin, Password: admin123"
echo ""
echo "🔍 Access Prometheus:"
echo "   kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090"
