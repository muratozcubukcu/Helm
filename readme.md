# Nginx App Helm Chart

A Helm chart for deploying a simple nginx web server to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Installation

### Basic Installation

```bash
# Install the chart
helm install my-nginx-app .

# Install with a custom release name
helm install my-release .

# Install in a specific namespace
helm install my-nginx-app . --namespace my-namespace --create-namespace
```

### Installation with Custom Values

```bash
# Install with custom values file
helm install my-nginx-app . -f custom-values.yaml

# Install with inline values
helm install my-nginx-app . --set replicaCount=3 --set image.tag=1.24
```

## Configuration

The following table lists the configurable parameters of the nginx-app chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of nginx replicas | `1` |
| `image.repository` | Nginx image repository | `nginx` |
| `image.tag` | Nginx image tag | `1.25` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |
| `podAnnotations` | Pod annotations | `{}` |
| `podSecurityContext` | Pod security context | `{}` |
| `securityContext` | Container security context | `{}` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Service target port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts | `[{host: chart-example.local, paths: [{path: /, pathType: ImplementationSpecific}]}]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |
| `resources` | Resource limits and requests | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |
| `nginxConfig.customConfig` | Custom nginx.conf content | `""` |
| `nginxConfig.customDefaultConf` | Custom default.conf content | `""` |
| `livenessProbe` | Liveness probe configuration | See values.yaml |
| `readinessProbe` | Readiness probe configuration | See values.yaml |

### Example Custom Values

```yaml
# custom-values.yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.25"

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

ingress:
  enabled: true
  className: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Usage

### Basic Usage

1. **Install the chart:**
   ```bash
   helm install my-nginx-app .
   ```

2. **Check the status:**
   ```bash
   kubectl get pods -l app.kubernetes.io/name=nginx-app
   ```

3. **Access the application:**
   - For ClusterIP: Use port-forward
   - For LoadBalancer: Wait for external IP
   - For NodePort: Use node IP and port
   - For Ingress: Access via configured hostname

### Custom Nginx Configuration

You can provide custom nginx configuration:

```yaml
nginxConfig:
  customConfig: |
    events {
      worker_connections 1024;
    }
    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;
      sendfile on;
      keepalive_timeout 65;
      server {
        listen 80;
        server_name localhost;
        location / {
          root /usr/share/nginx/html;
          index index.html index.htm;
        }
      }
    }
  customDefaultConf: |
    server {
      listen 80;
      server_name localhost;
      location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
      }
    }
```

### Scaling

```bash
# Scale to 3 replicas
helm upgrade my-nginx-app . --set replicaCount=3

# Or update values file and upgrade
helm upgrade my-nginx-app . -f custom-values.yaml
```

## Uninstalling the Chart

```bash
helm uninstall my-nginx-app
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/name=nginx-app
kubectl describe pod <pod-name>
```

### Check Logs
```bash
kubectl logs -l app.kubernetes.io/name=nginx-app
```

### Check Service
```bash
kubectl get svc -l app.kubernetes.io/name=nginx-app
kubectl describe svc <service-name>
```

### Port Forward for Testing
```bash
kubectl port-forward svc/<service-name> 8080:80
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

This project is licensed under the MIT License.
