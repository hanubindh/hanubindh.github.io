echo -n "Copy and Enter the PWK URL : " && read PWK_URL && cat hello-app.yaml | envsubst > out.yaml && kubectl apply -f out.yaml && rm -f out.yaml
