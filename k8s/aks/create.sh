rg="myaks"
loc="eastus"
aksCluster="myAKSCluster"
az group create --name "$rg" --location "$loc"
az aks create --resource-group "$rg" --name "$aksCluster" --node-count 2 --node-vm-size Standard_DS2_v2  --generate-ssh-keys
az aks get-credentials --resource-group "$rg" --name "$aksCluster"
