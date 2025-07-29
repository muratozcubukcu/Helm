#!/bin/bash

set -e

GIT_REPO_URL="https://github.com/muratozcubukcu/Helm.git"
ENVIRONMENT=${1:-production}
NAMESPACE="nginx-app-${ENVIRONMENT}"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists kubectl; then
    echo "kubectl is not installed"
    exit 1
fi

if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo "ArgoCD not found. Install with:"
    echo "kubectl create namespace argocd"
    echo "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

update_repo_url() {
    local file=$1
    if [ -f "$file" ]; then
        sed -i.bak "s|https://github.com/muratozcubukcu/Helm.git|${GIT_REPO_URL}|g" "$file"
        sed -i.bak "s|path: Helm|path: .|g" "$file"
    fi
}

update_repo_url "argocd-application.yaml"
update_repo_url "argocd-application-production.yaml"
update_repo_url "argocd-project.yaml"

kubectl apply -f argocd-project.yaml

if [ "$ENVIRONMENT" = "production" ]; then
    kubectl apply -f argocd-application-production.yaml
else
    kubectl apply -f argocd-application.yaml
fi

sleep 5

APP_NAME="nginx-app"
if [ "$ENVIRONMENT" = "production" ]; then
    APP_NAME="nginx-app-production"
fi

for i in {1..30}; do
    SYNC_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
    HEALTH_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")
    
    if [ "$SYNC_STATUS" = "Synced" ] && [ "$HEALTH_STATUS" = "Healthy" ]; then
        break
    fi
    
    sleep 10
done

kubectl get application $APP_NAME -n argocd
kubectl get all -n $NAMESPACE 2>/dev/null || echo "Namespace $NAMESPACE not found yet" 