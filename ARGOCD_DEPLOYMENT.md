# Deploying Nginx App with ArgoCD

This guide explains how to deploy the nginx Helm chart using ArgoCD for GitOps-based continuous deployment.

## Prerequisites

1. **ArgoCD Installed**: ArgoCD should be installed in your Kubernetes cluster
2. **Git Repository**: Your Helm chart should be in a Git repository
3. **Kubernetes Cluster**: Access to a Kubernetes cluster
4. **kubectl**: Configured to access your cluster

## Step 1: Prepare Your Git Repository

Ensure your Helm chart is committed to a Git repository:

```bash
# Initialize git if not already done
git init
git add .
git commit -m "Add nginx Helm chart"
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

## Step 2: Create ArgoCD Project (Optional but Recommended)

For better organization, create an ArgoCD project:

```bash
# Apply the project configuration
kubectl apply -f argocd-project.yaml
```

## Step 3: Deploy the Application

### Option A: Basic Deployment

```bash
# Apply the basic ArgoCD application
kubectl apply -f argocd-application.yaml
```

### Option B: Production Deployment

```bash
# Apply the production ArgoCD application
kubectl apply -f argocd-application-production.yaml
```

## Step 4: Verify Deployment

### Check Application Status

```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# Get detailed status
kubectl describe application nginx-app -n argocd
```

### Check Resources

```bash
# Check if namespace was created
kubectl get namespaces | grep nginx-app

# Check pods
kubectl get pods -n nginx-app-production

# Check services
kubectl get svc -n nginx-app-production

# Check ingress (if enabled)
kubectl get ingress -n nginx-app-production
```

## Step 5: Access ArgoCD UI

### Port Forward ArgoCD Server

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Access the UI

1. Open your browser and go to `https://localhost:8080`
2. Login with the ArgoCD admin credentials
3. Navigate to your application to see the deployment status

## Configuration Options

### Using Different Values Files

You can modify the ArgoCD application to use different values files:

```yaml
spec:
  source:
    helm:
      valueFiles:
        - values.yaml          # Default values
        - example-values.yaml  # Production values
        - custom-values.yaml   # Your custom values
```

### Inline Value Overrides

You can override values directly in the ArgoCD application:

```yaml
spec:
  source:
    helm:
      values: |
        replicaCount: 5
        service:
          type: LoadBalancer
        ingress:
          enabled: true
          hosts:
            - host: myapp.example.com
              paths:
                - path: /
                  pathType: Prefix
```

### Environment-Specific Configurations

Create different ArgoCD applications for different environments:

```bash
# Development
kubectl apply -f argocd-application-dev.yaml

# Staging
kubectl apply -f argocd-application-staging.yaml

# Production
kubectl apply -f argocd-application-production.yaml
```

## GitOps Workflow

### Making Changes

1. **Update your Helm chart** in the Git repository
2. **Commit and push** the changes
3. **ArgoCD automatically detects** the changes
4. **ArgoCD syncs** the changes to the cluster

### Example Workflow

```bash
# 1. Make changes to your values.yaml
vim values.yaml

# 2. Commit and push
git add values.yaml
git commit -m "Update nginx configuration"
git push origin main

# 3. ArgoCD will automatically sync (if auto-sync is enabled)
# Or manually sync via UI/CLI
```

### Manual Sync

If auto-sync is disabled, you can manually sync:

```bash
# Via kubectl
kubectl patch application nginx-app -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":null}}}'

# Via ArgoCD CLI
argocd app sync nginx-app

# Via ArgoCD UI
# Navigate to the application and click "Sync"
```

## Monitoring and Troubleshooting

### Check Application Health

```bash
# Get application health status
kubectl get application nginx-app -n argocd -o jsonpath='{.status.health.status}'

# Get sync status
kubectl get application nginx-app -n argocd -o jsonpath='{.status.sync.status}'
```

### View Application Logs

```bash
# Check ArgoCD application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Check ArgoCD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Common Issues

1. **Authentication Issues**: Ensure your Git repository is accessible
2. **Helm Chart Issues**: Verify the chart structure and values
3. **Resource Quotas**: Check if namespace has sufficient resources
4. **Network Policies**: Ensure ArgoCD can reach your Git repository

## Advanced Configurations

### Using Private Git Repositories

For private repositories, configure SSH keys or tokens:

```yaml
spec:
  source:
    repoURL: git@github.com:your-username/your-repo.git
    # Or use HTTPS with credentials
    # repoURL: https://github.com/your-username/your-repo.git
```

### Multi-Cluster Deployment

Deploy to multiple clusters:

```yaml
spec:
  destination:
    server: https://cluster2.example.com  # Different cluster
    namespace: nginx-app
```

### Using Helm Charts from Helm Repositories

If your chart is in a Helm repository:

```yaml
spec:
  source:
    repoURL: https://charts.example.com
    chart: nginx-app
    targetRevision: 0.1.0
```

## Best Practices

1. **Use Projects**: Organize applications with ArgoCD projects
2. **Enable Auto-Sync**: For development environments
3. **Manual Sync**: For production environments
4. **Health Checks**: Monitor application health
5. **RBAC**: Use proper role-based access control
6. **Backup**: Regularly backup ArgoCD configuration
7. **Monitoring**: Set up alerts for sync failures

## Cleanup

To remove the deployment:

```bash
# Delete the ArgoCD application
kubectl delete application nginx-app -n argocd

# Delete the project (if created)
kubectl delete appproject production -n argocd

# Delete the namespace (optional)
kubectl delete namespace nginx-app-production
``` 