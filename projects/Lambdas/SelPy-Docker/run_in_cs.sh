#!/bin/bash

BASE_PATH="https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy-Docker"

DOCKER_FILE="Dockerfile"
FUN_FILE="lambda_function.py"
EXECUTER="deploy_with_cs.sh"


echo "Creating temp dir"
temp_dir=$(mktemp -d)

if [ -z "$temp_dir" ]; then
  echo "Error: Failed to create temporary directory."
  exit 1
fi
echo "Temporary directory created: $temp_dir"
echo "$temp_dir" # return the value

cd "$temp_dir"

curl -sfSL "${BASE_PATH}/${DOCKER_FILE}" -o "${DOCKER_FILE}"
curl -sfSL "${BASE_PATH}/${FUN_FILE}" -o "${FUN_FILE}"
curl -sfSL "${BASE_PATH}/${EXECUTER}" -o "${EXECUTER}"
chmod +x "./${EXECUTER}" 
cd ~
rm -rf "$temp_dir"

echo "Script finished"
