1. Build docker image (optional)
   Go to Docker Lab playground and open a new instance. The issue following commands:

   curl https://hanubindh.github.io/k8s/hello/hello-image.tgz --output hello-image.tgz
   tar -zxvf hello-image.tgz
   cd hello-image
2. Go to K8S Playground and Deploy K8S manifest

    kubectl apply -f https://hanubindh.github.io/k8s/hello/hello.yaml

3. Check for the status
    kubectl get pods -o wide
    kubectl get svc hello-service
    kubectl get nodes
