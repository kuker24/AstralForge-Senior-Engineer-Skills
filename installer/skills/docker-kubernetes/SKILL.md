---
name: docker-kubernetes
description: Containerize applications with Docker and deploy to Kubernetes. Use when creating Dockerfiles, docker-compose, K8s manifests, or CI/CD pipelines.
---

# Docker & Kubernetes

## When to Use

- Creating Dockerfiles for applications
- Setting up docker-compose for local development
- Writing Kubernetes Deployment, Service, ConfigMap, Secret
- Implementing health checks and probes
- Optimizing image size with multi-stage builds

## Input

- Application source code
- Dependencies and environment requirements
- Deployment target (local, cloud, K8s cluster)

## Output

- Dockerfile with multi-stage build
- docker-compose.yml for local dev
- Kubernetes manifests (Deployment, Service, ConfigMap, Secret)
- CI/CD integration

## Checklist

1. **Dockerfile**
   - Use official base images
   - Multi-stage build for smaller images
   - Non-root user for security
   - Proper .dockerignore
   - Health check instruction

2. **docker-compose.yml**
   - Define services, networks, volumes
   - Environment variables
   - Port mappings
   - Depends_on for service dependencies

3. **Kubernetes Manifests**
   - Deployment with replicas
   - Service for networking
   - ConfigMap for configuration
   - Secret for sensitive data
   - Ingress for external access

4. **Probes**
   - Readiness probe: when ready to accept traffic
   - Liveness probe: when to restart
   - Startup probe: when initialization complete

## Best Practices

- Use specific image tags, not `latest`
- Minimize image layers
- Use multi-stage builds
- Run as non-root user
- Use .dockerignore
- Set resource limits in K8s
- Use liveness/readiness probes

## Anti-Patterns

❌ Running as root
❌ Using `latest` tag
❌ Storing secrets in image
❌ No health checks
❌ Large image sizes
❌ Hardcoded configuration

## Validation

- Image builds successfully
- Container runs as non-root
- Health checks pass
- Image size < 500MB (ideally < 200MB)
- No secrets in image layers

## Examples

### Example 1: Multi-stage Dockerfile
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
USER nextjs
EXPOSE 3000
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### Example 2: Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:1.0.0
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 15
          periodSeconds: 20
```

## Output Structure

```
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── ingress.yaml
```
