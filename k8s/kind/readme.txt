0. Install Kind
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
    sudo mv ./kind /usr/local/bin/kind
    chmod +x /usr/local/bin/kind


1. Create Kind cluster
    kind create cluster --config kind.yaml

2. Confirm that your Kind cluster is up and running (my-cluster is the name of
    the cluster as defined in kind manifest)   
    kubectl cluster-info --context kind-my-cluster

3. Deploy K8S manifest for hello-app
    kubectl apply -f hello-app.yaml

4. Verify deployment
    4.1 Check pod status
        kubectl get pods
    4.2 Check Service Status
        kubectl get svc hello-service
5. Access the FastAPI Service
    curl http://localhost:30080/

6. Cleanup (Optional)
    kind delete cluster --name my-cluster
