#!/bin/bash

# ArgoCD Deployment Script for Nginx App
# This script helps deploy the nginx Helm chart using ArgoCD

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GIT_REPO_URL="https://github.com/muratozcubukcu/Helm.git"
ENVIRONMENT=${1:-production}
NAMESPACE="nginx-app-${ENVIRONMENT}"

echo -e "${BLUE}🚀 ArgoCD Deployment Script for Nginx App${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Namespace: ${NAMESPACE}${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command_exists kubectl; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

if ! command_exists git; then
    echo -e "${RED}❌ git is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Check if ArgoCD is installed
echo -e "${YELLOW}🔍 Checking ArgoCD installation...${NC}"
if ! kubectl get namespace argocd >/dev/null 2>&1; then
    echo -e "${RED}❌ ArgoCD namespace not found. Please install ArgoCD first.${NC}"
    echo -e "${YELLOW}💡 You can install ArgoCD using:${NC}"
    echo "kubectl create namespace argocd"
    echo "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

echo -e "${GREEN}✅ ArgoCD is installed${NC}"

# Update Git repository URL in ArgoCD application files
echo -e "${YELLOW}🔧 Updating Git repository URL...${NC}"

# Function to update repo URL in a file
update_repo_url() {
    local file=$1
    if [ -f "$file" ]; then
        sed -i.bak "s|https://github.com/your-username/your-repo.git|${GIT_REPO_URL}|g" "$file"
        echo -e "${GREEN}✅ Updated ${file}${NC}"
    fi
}

update_repo_url "argocd-application.yaml"
update_repo_url "argocd-application-production.yaml"
update_repo_url "argocd-project.yaml"

# Create ArgoCD project
echo -e "${YELLOW}📁 Creating ArgoCD project...${NC}"
kubectl apply -f argocd-project.yaml
echo -e "${GREEN}✅ ArgoCD project created${NC}"

# Deploy application based on environment
echo -e "${YELLOW}🚀 Deploying nginx application...${NC}"

if [ "$ENVIRONMENT" = "production" ]; then
    kubectl apply -f argocd-application-production.yaml
    echo -e "${GREEN}✅ Production application deployed${NC}"
else
    kubectl apply -f argocd-application.yaml
    echo -e "${GREEN}✅ Development application deployed${NC}"
fi

# Wait for application to be created
echo -e "${YELLOW}⏳ Waiting for application to be created...${NC}"
sleep 5

# Check application status
echo -e "${YELLOW}📊 Checking application status...${NC}"
APP_NAME="nginx-app"
if [ "$ENVIRONMENT" = "production" ]; then
    APP_NAME="nginx-app-production"
fi

# Wait for application to sync
echo -e "${YELLOW}⏳ Waiting for application to sync...${NC}"
for i in {1..30}; do
    SYNC_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
    HEALTH_STATUS=$(kubectl get application $APP_NAME -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")
    
    echo -e "${BLUE}Sync Status: ${SYNC_STATUS}, Health: ${HEALTH_STATUS}${NC}"
    
    if [ "$SYNC_STATUS" = "Synced" ] && [ "$HEALTH_STATUS" = "Healthy" ]; then
        echo -e "${GREEN}✅ Application is synced and healthy!${NC}"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo -e "${YELLOW}⚠️  Application sync is taking longer than expected${NC}"
        echo -e "${YELLOW}💡 You can check the status manually:${NC}"
        echo "kubectl get application $APP_NAME -n argocd"
        echo "kubectl describe application $APP_NAME -n argocd"
    fi
    
    sleep 10
done

# Display final status
echo -e "${BLUE}📋 Final Application Status:${NC}"
kubectl get application $APP_NAME -n argocd

echo -e "${BLUE}📋 Resources in namespace ${NAMESPACE}:${NC}"
kubectl get all -n $NAMESPACE 2>/dev/null || echo "Namespace $NAMESPACE not found yet (may still be creating)"

# Display access information
echo ""
echo -e "${GREEN}🎉 Deployment completed!${NC}"
echo ""
echo -e "${BLUE}📖 Next steps:${NC}"
echo "1. Access ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Check application logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=nginx-app"
echo "3. Access your application:"
echo "   - For LoadBalancer: kubectl get svc -n $NAMESPACE"
echo "   - For port-forward: kubectl port-forward svc/nginx-app -n $NAMESPACE 8080:80"
echo ""
echo -e "${BLUE}🔧 Useful commands:${NC}"
echo "kubectl get application $APP_NAME -n argocd"
echo "kubectl describe application $APP_NAME -n argocd"
echo "kubectl get pods -n $NAMESPACE"
echo "kubectl get svc -n $NAMESPACE" 