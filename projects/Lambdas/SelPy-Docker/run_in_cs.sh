#!/bin/bash

BASE_PATH="https://raw.githubusercontent.com/hanubindh/hanubindh.github.io/refs/heads/master/projects/Lambdas/SelPy-Docker"

DOCKER_FILE="Dockerfile"
FUN_FILE="lambda_function.py"
EXECUTER="deploy_with_cs.sh"

create_dir() {
  echo "Creating temp dir"
  temp_dir=$(mktemp -d)

  if [ -z "$temp_dir" ]; then
    echo "Error: Failed to create temporary directory."
    exit 1
  fi
  echo "Temporary directory created: $temp_dir"
  echo "$temp_dir" # return the value
}

download_files() {
  local temp_dir="$1"
  echo "Downloading files to $temp_dir"
  curl -sfSL "${BASE_PATH}/${DOCKER_FILE}" -o "${temp_dir}/${DOCKER_FILE}" || { echo "Error downloading ${DOCKER_FILE}"; exit 1; }
  curl -sfSL "${BASE_PATH}/${FUN_FILE}" -o "${temp_dir}/${FUN_FILE}" || { echo "Error downloading ${FUN_FILE}"; exit 1; }
  curl -sfSL "${BASE_PATH}/${EXECUTER}" -o "${temp_dir}/${EXECUTER}" || { echo "Error downloading ${EXECUTER}"; exit 1; }
  chmod +x "${temp_dir}/${EXECUTER}" || { echo "Error setting execute permissions"; exit 1; }
  echo "Files downloaded"
}

start_execution() {
  local temp_dir="$1"
  echo "Executing ${EXECUTER}"
  "${temp_dir}/${EXECUTER}" || { echo "Error executing ${EXECUTER}"; exit 1; }
  echo "Execution complete"
}

cleanup() {
  local temp_dir="$1"
  if [ -n "$temp_dir" ]; then
    echo "Cleaning up $temp_dir"
    rm -rf "$temp_dir"
  fi
}

temp_dir=$(create_dir)
trap "cleanup $temp_dir" EXIT

download_files "$temp_dir"
start_execution "$temp_dir"

echo "Script finished"
