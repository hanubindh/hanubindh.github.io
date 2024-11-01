rg="myaks"
loc="eastus"
aksCluster="myAKSCluster"

az aks delete --resource-group "$rg" --name "$aksCluster"
az group delete --name "$rg"

