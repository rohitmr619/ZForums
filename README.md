# 🏛️ ZForums - Simple Fullstack Forums Application

A modern, scalable forums application built with React, Node.js, Express, and PostgreSQL, designed for deployment on Kubernetes (k3s) with Traefik ingress and Helm charts.

## 🚀 Features

- **Modern UI**: Clean, responsive React frontend
- **REST API**: Express.js backend with PostgreSQL database
- **Cloud Native**: Kubernetes-ready with Helm charts
- **Auto-scaling**: Horizontal Pod Autoscaler configuration
- **Production Ready**: Security best practices, health checks, and monitoring
- **Persistent Storage**: PostgreSQL with persistent volumes

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Traefik      │    │   ZForums App   │    │   PostgreSQL    │
│   (Ingress)    │───▶│   (Frontend +   │───▶│   (Database)    │
│                │    │    Backend)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        │                       │                       │
    Port 80/443            Port 3000               Port 5432
```

## 📋 Prerequisites

- k3s cluster (or any Kubernetes cluster)
- kubectl configured
- Helm 3.x installed
- Docker (for building images)

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ZForums
```

### 2. Build the Application

```bash
# Install dependencies
npm run install-all

# Build React frontend
npm run build

# Build Docker image
./scripts/build-and-push.sh
```

### 3. Setup Traefik (if not already installed)

```bash
./scripts/setup-traefik.sh
```

### 4. Deploy to k3s

```bash
./scripts/deploy-k3s.sh
```

### 5. Access the Application

```bash
# Port forward to access locally
kubectl port-forward -n zforums svc/zforums 8080:80

# Open in browser
open http://localhost:8080
```

## 🔧 Configuration

### Helm Values

Key configuration options in `helm/zforums/values.yaml`:

```yaml
# Scaling configuration
replicaCount: 2
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10

# Database configuration
postgresql:
  enabled: true
  auth:
    database: "zforums"
    username: "zforums"
    password: "ZForumsPassword123!"

# Ingress configuration
ingress:
  enabled: true
  className: "traefik"
  hosts:
    - host: zforums.local
```

### Environment Variables

The application supports these environment variables:

- `PORT`: Application port (default: 3000)
- `DB_HOST`: PostgreSQL host
- `DB_PORT`: PostgreSQL port (default: 5432)
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `NODE_ENV`: Environment (production/development)

## 🏃‍♂️ Development

### Local Development

```bash
# Install dependencies
npm run install-all

# Start development servers
npm run dev
```

This starts:
- Backend server on http://localhost:3000
- React dev server on http://localhost:3001

### Database Setup

For local development, you can use Docker:

```bash
docker run -d \
  --name postgres-dev \
  -e POSTGRES_DB=zforums \
  -e POSTGRES_USER=zforums \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:16-alpine
```

## 🔐 Security Features

- **Non-root containers**: Runs as user ID 1001
- **Read-only root filesystem**: Enhanced security
- **Security contexts**: Proper Kubernetes security contexts
- **Secrets management**: Database credentials stored in Kubernetes secrets
- **Helmet.js**: Security headers for Express.js

## 📊 Monitoring & Health Checks

- **Health endpoint**: `/health` for Kubernetes probes
- **Liveness probes**: Application health monitoring
- **Readiness probes**: Traffic routing control
- **Resource limits**: CPU and memory constraints

## 🔄 Auto-scaling

The application includes Horizontal Pod Autoscaler (HPA) configuration:

- **CPU-based scaling**: Scales based on CPU utilization (70%)
- **Memory-based scaling**: Scales based on memory utilization (80%)
- **Min replicas**: 2 (for high availability)
- **Max replicas**: 10 (configurable)

## 🗃️ Database

- **PostgreSQL 16**: Latest stable version
- **Persistent storage**: 8Gi persistent volume
- **Backup ready**: Standard PostgreSQL backup tools compatible
- **Connection pooling**: Built-in Node.js connection pooling

## 🌐 Networking

- **Traefik Ingress**: Advanced ingress controller
- **TLS/SSL**: Automatic HTTPS with cert-manager support
- **Load balancing**: Built-in load balancing across pods
- **Service mesh ready**: Compatible with Istio/Linkerd

## 📝 API Endpoints

- `GET /api/posts` - List all forum posts
- `POST /api/posts` - Create a new post
- `GET /api/posts/:id` - Get a specific post
- `GET /health` - Health check endpoint

## 🔍 Troubleshooting

### Common Issues

1. **PostgreSQL not connecting**:
   ```bash
   kubectl logs -n zforums deployment/zforums-postgresql
   ```

2. **Application not starting**:
   ```bash
   kubectl logs -n zforums deployment/zforums
   ```

3. **Ingress not working**:
   ```bash
   kubectl get ingress -n zforums
   kubectl describe ingress -n zforums zforums
   ```

### Useful Commands

```bash
# Check pod status
kubectl get pods -n zforums

# View application logs
kubectl logs -n zforums -l app.kubernetes.io/name=zforums

# Access PostgreSQL
kubectl exec -it -n zforums deployment/zforums-postgresql -- psql -U zforums -d zforums

# Port forward to database
kubectl port-forward -n zforums svc/zforums-postgresql 5432:5432
```

## 🚀 Production Deployment

For production deployment:

1. **Use external PostgreSQL**: Disable built-in PostgreSQL and use managed database
2. **Configure TLS**: Setup cert-manager for automatic SSL certificates
3. **Resource limits**: Adjust CPU/memory limits based on load testing
4. **Monitoring**: Add Prometheus/Grafana monitoring
5. **Backup strategy**: Implement database backup procedures

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For issues and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section above
- Review Kubernetes logs for debugging

---

Built with ❤️ for the Kubernetes community
