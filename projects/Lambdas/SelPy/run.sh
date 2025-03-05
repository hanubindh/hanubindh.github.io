#!/bin/bash

set -euo pipefail

S_PATH="https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy/run.sh"
T_DIR="SelPy"

# Check if the target directory exists and remove it safely
if [ -d "${T_DIR}" ]; then
  echo "Removing existing directory: ${T_DIR}"
  rm -rf "${T_DIR}"
fi

# Create the target directory
mkdir "${T_DIR}"
cd "${T_DIR}"

# Download, decode, and extract the files
curl -s "${S_PATH}" | openssl base64 -d | tar -zxv
if [ $? -ne 0 ]; then
  echo "Error downloading or extracting files."
  exit 1
fi

# Make deploy.sh executable and run it
chmod +x deploy.sh
./deploy.sh

# Clean up
cd ..
rm -rf "${T_DIR}"

echo "Script execution complete."
