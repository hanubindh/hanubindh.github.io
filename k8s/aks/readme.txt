1. Create AKS cluster and verify (Azure CLI must be installed)
    curl https://hanubindh.github.io/k8s/aks/create.sh --output create.sh && chmod +x create.sh && ./create.sh
    kubectl get nodes
2. kubectl apply -f https://hanubindh.github.io/k8s/aks/hello-app.yaml
3. Verify deployment
    3.1 Check pod status
        kubectl get pods
    3.2 Check Service Status
        kubectl get svc fast-hello-service