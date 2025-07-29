# ArgoCD Cheatsheet

Quick reference for common ArgoCD operations when working with the nginx Helm chart.

## 🚀 Quick Start

```bash
# Deploy using the script
./deploy-argocd.sh production

# Or manually
kubectl apply -f argocd-application-production.yaml
```

## 📋 Application Management

### Check Application Status
```bash
# List all applications
kubectl get applications -n argocd

# Get detailed status
kubectl describe application nginx-app-production -n argocd

# Check sync status
kubectl get application nginx-app-production -n argocd -o jsonpath='{.status.sync.status}'

# Check health status
kubectl get application nginx-app-production -n argocd -o jsonpath='{.status.health.status}'
```

### Sync Operations
```bash
# Manual sync
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":null}}}'

# Force sync
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":null}}}'

# Enable auto-sync
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

## 🔍 Monitoring and Debugging

### View Logs
```bash
# ArgoCD application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# ArgoCD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Nginx application logs
kubectl logs -n nginx-app-production -l app.kubernetes.io/name=nginx-app
```

### Check Resources
```bash
# Check pods
kubectl get pods -n nginx-app-production

# Check services
kubectl get svc -n nginx-app-production

# Check ingress
kubectl get ingress -n nginx-app-production

# Check all resources
kubectl get all -n nginx-app-production
```

## 🌐 Access Applications

### ArgoCD UI
```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
```

### Nginx Application
```bash
# Port forward nginx service
kubectl port-forward svc/nginx-app-production -n nginx-app-production 8080:80

# Access at http://localhost:8080
```

## 🔧 Configuration Updates

### Update Values
```bash
# Update inline values
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"helm":{"values":"replicaCount: 5"}}}}'

# Update from different branch
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"targetRevision":"feature/new-config"}}}'
```

### Rollback
```bash
# Rollback to previous revision
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"targetRevision":"HEAD~1"}}}'
```

## 🗑️ Cleanup

### Delete Application
```bash
# Delete application
kubectl delete application nginx-app-production -n argocd

# Delete with cascade
kubectl delete application nginx-app-production -n argocd --cascade=true
```

### Delete Project
```bash
# Delete project
kubectl delete appproject production -n argocd
```

## 📊 Health Checks

### Application Health
```bash
# Get health status
kubectl get application nginx-app-production -n argocd -o jsonpath='{.status.health.status}'

# Get health message
kubectl get application nginx-app-production -n argocd -o jsonpath='{.status.health.message}'
```

### Resource Health
```bash
# Check deployment health
kubectl get deployment nginx-app-production -n nginx-app-production -o jsonpath='{.status.conditions[?(@.type=="Available")].status}'

# Check service health
kubectl get svc nginx-app-production -n nginx-app-production
```

## 🔐 Authentication

### Get ArgoCD Admin Password
```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Login via CLI
```bash
# Login to ArgoCD
argocd login localhost:8080 --username admin --password <password>

# List applications
argocd app list

# Sync application
argocd app sync nginx-app-production
```

## 🚨 Troubleshooting

### Common Issues

1. **Sync Failed**
   ```bash
   # Check sync status
   kubectl describe application nginx-app-production -n argocd
   
   # Check events
   kubectl get events -n nginx-app-production --sort-by='.lastTimestamp'
   ```

2. **Health Degraded**
   ```bash
   # Check pod status
   kubectl describe pod -n nginx-app-production -l app.kubernetes.io/name=nginx-app
   
   # Check logs
   kubectl logs -n nginx-app-production -l app.kubernetes.io/name=nginx-app
   ```

3. **Git Repository Issues**
   ```bash
   # Check repository connectivity
   kubectl describe application nginx-app-production -n argocd | grep -A 10 "Source"
   
   # Test git access
   kubectl exec -n argocd deployment/argocd-repo-server -- git ls-remote <repo-url>
   ```

### Debug Commands
```bash
# Get application manifest
kubectl get application nginx-app-production -n argocd -o yaml

# Get application events
kubectl get events -n argocd --field-selector involvedObject.name=nginx-app-production

# Check ArgoCD server status
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
```

## 📈 Scaling and Performance

### Scale Application
```bash
# Scale via ArgoCD
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"helm":{"values":"replicaCount: 10"}}}}'

# Scale directly
kubectl scale deployment nginx-app-production -n nginx-app-production --replicas=10
```

### Resource Monitoring
```bash
# Check resource usage
kubectl top pods -n nginx-app-production

# Check node resources
kubectl top nodes
```

## 🔄 GitOps Workflow

### Typical Workflow
```bash
# 1. Make changes to Git repository
git add .
git commit -m "Update nginx configuration"
git push origin main

# 2. ArgoCD automatically detects changes (if auto-sync enabled)
# Or manually sync
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":null}}}'

# 3. Monitor deployment
kubectl get application nginx-app-production -n argocd -w
```

### Branch-based Deployment
```bash
# Deploy from feature branch
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"targetRevision":"feature/new-feature"}}}'

# Deploy from specific commit
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"targetRevision":"abc123"}}}'
``` 