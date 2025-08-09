#!/bin/bash

# Complete deployment script for ZForums on k3s
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
NAMESPACE="zforums"
REGISTRY="${REGISTRY:-localhost:5000}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

print_status "🚀 Starting full deployment of ZForums to k3s..."

# Check prerequisites
print_status "🔍 Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    print_error "helm is not installed or not in PATH"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "docker is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
if ! sudo kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_success "All prerequisites met!"

# Step 1: Build and push the application
print_status "🏗️  Building ZForums application..."
cd "$(dirname "$0")/.."

# Install dependencies
print_status "📦 Installing dependencies..."
npm install --silent
cd client && npm install --silent && cd ..

# Build React app
print_status "⚛️  Building React frontend..."
cd client && npm run build && cd ..

# Build Docker image for local k3s
print_status "🐳 Building Docker image..."
sudo docker build -t "zforums/app:${IMAGE_TAG}" .

# Import image into k3s
print_status "📦 Importing image into k3s..."
sudo docker save zforums/app:${IMAGE_TAG} | sudo k3s ctr images import -

print_success "Image built and imported into k3s"

# Step 2: Setup Traefik if needed
print_status "🔧 Checking Traefik installation..."
if ! sudo kubectl get ingressclass traefik &>/dev/null; then
    print_status "Installing Traefik ingress controller..."
    ./scripts/setup-traefik.sh
else
    print_success "Traefik already installed"
fi

# Step 3: Deploy with Helm
print_status "🎯 Deploying ZForums with Helm..."

# Add Bitnami repo for PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update

# Create namespace
sudo kubectl create namespace $NAMESPACE --dry-run=client -o yaml | sudo kubectl apply -f -

# Deploy with custom values for local development
KUBECONFIG=/etc/rancher/k3s/k3s.yaml sudo -E helm upgrade --install zforums ./helm/zforums \
    --namespace $NAMESPACE \
    --set image.repository="zforums/app" \
    --set image.tag="${IMAGE_TAG}" \
    --set image.pullPolicy="Never" \
    --set ingress.hosts[0].host="zforums.local" \
    --set postgresql.auth.postgresPassword="SecurePassword123!" \
    --set postgresql.auth.password="ZForumsPassword123!" \
    --wait \
    --timeout 600s

# Step 4: Wait for deployment
print_status "⏳ Waiting for pods to be ready..."
sudo kubectl wait --for=condition=ready pod --selector=app.kubernetes.io/name=zforums --namespace=$NAMESPACE --timeout=300s

# Step 5: Display status
print_success "🎉 ZForums deployed successfully!"
echo ""
print_status "📋 Deployment status:"
sudo kubectl get pods -n $NAMESPACE
echo ""
sudo kubectl get services -n $NAMESPACE
echo ""
sudo kubectl get ingress -n $NAMESPACE

# Step 6: Setup local access
print_status "🌐 Setting up local access..."

# Add to /etc/hosts if not already there
if ! grep -q "zforums.local" /etc/hosts 2>/dev/null; then
    print_status "Adding zforums.local to /etc/hosts..."
    echo "127.0.0.1 zforums.local" | sudo tee -a /etc/hosts
    print_success "Added zforums.local to /etc/hosts"
fi

# Display access information
echo ""
print_success "🎯 Access information:"
echo "  🌍 Web Interface: http://zforums.local"
echo "  📱 Local Access: kubectl port-forward -n $NAMESPACE svc/zforums 8080:80"
echo "  🗃️  Database: kubectl port-forward -n $NAMESPACE svc/zforums-postgresql 5432:5432"
echo ""
print_success "🎭 Traefik Dashboard: kubectl port-forward -n traefik-system svc/traefik 9000:9000"
echo "     Then visit: http://localhost:9000/dashboard/"
echo ""

# Display useful commands
print_status "🔧 Useful commands:"
echo "  📊 View logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=zforums"
echo "  🔍 Debug pods: kubectl describe pods -n $NAMESPACE"
echo "  🗑️  Cleanup: helm uninstall zforums -n $NAMESPACE"
echo ""

print_success "✅ Full deployment completed successfully!"
