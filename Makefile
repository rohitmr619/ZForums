# ZForums Makefile for easy operations

.PHONY: help install build dev deploy clean status logs

# Default target
help:
	@echo "🏛️  ZForums - Available commands:"
	@echo ""
	@echo "📦 Development:"
	@echo "  make install    - Install all dependencies"
	@echo "  make build      - Build the application"
	@echo "  make dev        - Start development servers"
	@echo ""
	@echo "🚀 Deployment:"
	@echo "  make deploy     - Full deployment to k3s"
	@echo "  make status     - Check deployment status"
	@echo "  make logs       - View application logs"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean      - Clean up deployment"
	@echo "  make rebuild    - Clean, build, and deploy"

# Development commands
install:
	@echo "📦 Installing dependencies..."
	npm install
	cd client && npm install

build:
	@echo "🏗️  Building application..."
	cd client && npm run build
	docker build -t zforums/app:latest .

dev:
	@echo "🔧 Starting development servers..."
	npm run dev

# Deployment commands
deploy:
	@echo "🚀 Deploying to k3s..."
	./scripts/full-deploy.sh

status:
	@echo "📊 Checking deployment status..."
	@kubectl get pods -n zforums
	@echo ""
	@kubectl get services -n zforums
	@echo ""
	@kubectl get ingress -n zforums

logs:
	@echo "📋 Application logs:"
	kubectl logs -n zforums -l app.kubernetes.io/name=zforums --tail=50

# Maintenance commands
clean:
	@echo "🧹 Cleaning up deployment..."
	helm uninstall zforums -n zforums || true
	kubectl delete namespace zforums || true

rebuild: clean build deploy

# Quick access commands
port-forward:
	@echo "🌐 Setting up port forwarding..."
	kubectl port-forward -n zforums svc/zforums 8080:80

db-connect:
	@echo "🗃️  Connecting to database..."
	kubectl exec -it -n zforums deployment/zforums-postgresql -- psql -U zforums -d zforums

traefik-dashboard:
	@echo "🎭 Opening Traefik dashboard..."
	kubectl port-forward -n traefik-system svc/traefik 9000:9000
