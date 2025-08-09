#!/bin/bash
set -e

echo "🚀 Setting up ArgoCD for Continuous Delivery..."

# Create argocd namespace
sudo kubectl create namespace argocd --dry-run=client -o yaml | sudo kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
sudo kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Patch ArgoCD server service to NodePort for access
echo "🌐 Configuring ArgoCD access..."
sudo kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"protocol":"TCP","targetPort":8080,"nodePort":30443}]}}'

# Get initial admin password
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD installed successfully!"
echo ""
echo "🎯 Access ArgoCD:"
echo "   URL: https://192.168.1.13:30443"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🔧 Port-forward alternative:"
echo "   kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "   Then: https://localhost:8080"
echo ""
echo "📝 Password saved to: /tmp/argocd-admin-password"
echo "$ARGOCD_PASSWORD" > /tmp/argocd-admin-password
