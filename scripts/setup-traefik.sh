#!/bin/bash

# Setup Traefik ingress controller on k3s
set -e

echo "🔧 Setting up Traefik ingress controller for k3s..."

# Check if kubectl is available
if ! sudo kubectl version --client &> /dev/null; then
    echo "❌ kubectl is not available with sudo"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    exit 1
fi

# Add Traefik Helm repository
echo "📦 Adding Traefik Helm repository..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Create traefik namespace
echo "📂 Creating traefik-system namespace..."
sudo kubectl create namespace traefik-system --dry-run=client -o yaml | sudo kubectl apply -f -

# Install/upgrade Traefik
echo "🚀 Installing Traefik ingress controller..."
KUBECONFIG=/etc/rancher/k3s/k3s.yaml sudo -E helm upgrade --install traefik traefik/traefik \
    --namespace traefik-system \
    --set "additionalArguments={--api.insecure=true,--log.level=INFO}" \
    --set "ports.traefik.expose=true" \
    --set "ports.web.redirectTo=websecure" \
    --set "ports.websecure.tls.enabled=true" \
    --set "globalArguments={--global.checknewversion=false,--global.sendanonymoususage=false}" \
    --wait

# Create IngressClass for Traefik
echo "🏷️  Creating Traefik IngressClass..."
cat <<EOF | sudo kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: traefik
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: traefik.io/ingress-controller
EOF

# Wait for Traefik to be ready
echo "⏳ Waiting for Traefik to be ready..."
sudo kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=traefik --namespace=traefik-system --timeout=300s

# Get Traefik service details
echo "📋 Traefik service details:"
sudo kubectl get svc -n traefik-system

echo "✅ Traefik setup complete!"
echo ""
echo "🎯 Access Traefik dashboard:"
echo "   kubectl port-forward -n traefik-system svc/traefik 9000:9000"
echo "   Open: http://localhost:9000/dashboard/"
echo ""
echo "🌐 HTTP/HTTPS ports:"
echo "   HTTP: port 80"
echo "   HTTPS: port 443"
