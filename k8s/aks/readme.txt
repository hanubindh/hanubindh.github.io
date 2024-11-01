1. Create AKS cluster and verify (Azure CLI must be installed)
    curl https://hanubindh.github.io/k8s/aks/create.sh --output create.sh && chmod +x create.sh && ./create.sh
    kubectl get nodes
2. kubectl apply -f https://hanubindh.github.io/k8s/aks/hello-app.yaml
3. Verify deployment
    3.1 Check pod status
        kubectl get pods
    3.2 Check Service Status
        kubectl get svc fast-hello-service
4. Get the external IP using the command described in step 3.2 and invoke the service
    curl http://<EXTERNAL-IP>:80/hello
5. Cleanup (Optional)
    5.1 Delete local kubectl context
        kubectl config delete-context myAKSCluster
    5.2 curl https://hanubindh.github.io/k8s/aks/delete.sh --output delete.sh && chmod +x delete.sh && ./delete.sh
