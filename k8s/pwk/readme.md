
# Setup K8S cluster in PW:

**Step 1**: Initialize the cluster

    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16 &&\
    kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

**Step 2**: Get the command to join nodes

    kubeadm token create --print-join-command

**Step 3**: Add nodes (In PWK, click "Add new instance" button to create new node instances) typing command obtained from 
         previous step 2.

**Step 4**: Verify issuing following command and ensure that all nodes are listed with ready status.
    
    kubectl get nodes


# Deploy "fast-hello" service:

**Step 1**: Deploy the manifest

    kubectl apply -f https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/k8s/pwk/hello-app.yaml

**Step 2**: Verify deployment

**Step 2.1**: Check pod status
    
    kubectl get pods
            
**Step 2.2**: Check Service Status
    
    kubectl get svc fast-hello-service
    
**Step 2.4**: Invoke service locally from any of the nodes using the Nodeport port configured in the manifest
    (Get node IP by issuing `kubectl get nodes -o wide` - Service can be accessed from any of the Node IPs)
    
    curl http://<NODE-IP>:30080/hello

Note: The service can now be accessed from public domain name of the PWK instance too. Copy the same from "URL" Textbox at the top.

# Undeploy "fast-hello" service:

**Step 1**: Delete deployment

    kubectl delete deployment fast-hello-deployment

**Step 2**: Delete service

    kubectl delete service fast-hello-service


