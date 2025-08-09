#!/bin/bash

# Deploy ZForums to k3s cluster
set -e

# Configuration
NAMESPACE="zforums"
HELM_RELEASE="zforums"
CHART_DIR="./helm/zforums"

echo "🚀 Deploying ZForums to k3s cluster..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
echo "🔍 Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

# Create namespace
echo "📦 Creating namespace: $NAMESPACE"
kubectl apply -f k8s/namespace.yaml

# Install/upgrade PostgreSQL dependency
echo "🗃️  Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Deploy with Helm
echo "🎯 Deploying ZForums with Helm..."
helm upgrade --install $HELM_RELEASE $CHART_DIR \
    --namespace $NAMESPACE \
    --create-namespace \
    --wait \
    --timeout 600s

echo "📋 Getting deployment status..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

echo "🎉 ZForums deployed successfully!"
echo ""
echo "📱 Access the application:"
echo "   Local (with port-forward): kubectl port-forward -n $NAMESPACE svc/$HELM_RELEASE 8080:80"
echo "   Ingress: http://zforums.local (make sure to add to /etc/hosts)"
echo ""
echo "🗃️  PostgreSQL connection:"
echo "   Host: $HELM_RELEASE-postgresql.$NAMESPACE.svc.cluster.local"
echo "   Port: 5432"
echo "   Database: zforums"
echo "   Username: zforums"
