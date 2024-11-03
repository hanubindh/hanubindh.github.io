Step 1: Initialize the cluster
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16 &&\
    kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

Step 2: Get the command to join nodes
    kubeadm token create --print-join-command

Step 3: Add nodes (In PWK, click "Add new instance" button to create new node instances) typing command obtained from 
         previous step 2.

Step 4: Verify issuing following command and ensure that all nodes are listed with ready status.
    kubectl get nodes