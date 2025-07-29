# ArgoCD Troubleshooting Guide

## 🚨 Common Error: "Helm: app path does not exist"

### Problem
```
ComparisonError
Failed to load target state: failed to generate manifest for source 1 of 1: rpc error: code = Unknown desc = Helm: app path does not exist
```

### Solution
The issue is that ArgoCD is looking for the Helm chart at the wrong path. Your Helm chart files are in the root directory, but ArgoCD was configured to look in a `Helm` subdirectory.

### Fix
Update your ArgoCD application to point to the root directory:

```bash
# Update the application path
kubectl patch application nginx-app-production -n argocd --type='merge' -p='{"spec":{"source":{"path":"."}}}'

# Or recreate the application with the corrected configuration
kubectl delete application nginx-app-production -n argocd
kubectl apply -f argocd-application-production.yaml
```

### Verification
```bash
# Check if the chart is valid locally
helm lint .

# Check application status
kubectl get application nginx-app-production -n argocd

# Check application details
kubectl describe application nginx-app-production -n argocd
```

## 🔧 Quick Fix Commands

```bash
# 1. Delete the problematic application
kubectl delete application nginx-app-production -n argocd

# 2. Apply the corrected configuration
kubectl apply -f argocd-application-production.yaml

# 3. Check status
kubectl get application nginx-app-production -n argocd
``` 