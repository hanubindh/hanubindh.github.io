#!/bin/sh

# Exit on error
set -e

# Global Variables
FUNCTION_NAME="SelPyContainerFun"
REGION="us-east-1"
ECR_REPO_NAME="$FUNCTION_NAME-repo"
IMAGE_TAG="latest"
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"
LAMBDA_FUN_ARN=""

fetch_latest_chrome_and_driver() {
    echo "Fetching latest Chrome for Testing version..."
    CHROME_VERSION=$(curl -sSL https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)
    echo "Latest Chrome version: $CHROME_VERSION"

    CHROME_URL="https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_VERSION}/linux64/chrome-linux64.zip"
    CHROME_DIR="chrome-bin"

    echo "Downloading Chrome binary from $CHROME_URL..."
    mkdir -p "$CHROME_DIR"
    curl -sSL "$CHROME_URL" -o chrome.zip
    unzip chrome.zip -d "$CHROME_DIR"
    rm chrome.zip

    echo "Fetching matching ChromeDriver version..."
    CHROMEDRIVER_URL="https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_VERSION}/linux64/chromedriver-linux64.zip"
    CHROMEDRIVER_DIR="chromedriver-bin"

    echo "Downloading ChromeDriver from $CHROMEDRIVER_URL..."
    mkdir -p "$CHROMEDRIVER_DIR"
    curl -sSL "$CHROMEDRIVER_URL" -o chromedriver.zip
    unzip chromedriver.zip -d "$CHROMEDRIVER_DIR"
    rm chromedriver.zip

    echo "Chrome and ChromeDriver downloaded successfully."
}

create_ecr_repo() {
    echo "Checking if ECR repository exists..."
    if ! aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" --region "$REGION" > /dev/null 2>&1; then
        echo "Creating ECR repository: $ECR_REPO_NAME"
        aws ecr create-repository --repository-name "$ECR_REPO_NAME" --region "$REGION"
    else
        echo "ECR repository already exists."
    fi
}

build_and_push_docker() {
    echo "Building Docker image..."
    docker build -t "$ECR_REPO_NAME" .

    echo "Authenticating with AWS ECR..."
    aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

    echo "Tagging and pushing image to ECR..."
    docker tag "$ECR_REPO_NAME" "$ECR_URI"
    docker push "$ECR_URI"
}

create_lambda_role() {
    echo "Ensuring IAM role exists..."
    if ! aws iam get-role --role-name "lambda-execution-role" > /dev/null 2>&1; then
        aws iam create-role --role-name lambda-execution-role \
            --assume-role-policy-document '{
                "Version": "2012-10-17",
                "Statement": [{
                    "Effect": "Allow",
                    "Principal": {"Service": "lambda.amazonaws.com"},
                    "Action": "sts:AssumeRole"
                }]
            }' \
            --region "$REGION"
        aws iam attach-role-policy --role-name lambda-execution-role \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        echo "IAM role created and policy attached."
    else
        echo "IAM role already exists."
    fi
}

deploy_lambda() {
    echo "Deploying AWS Lambda function..."
    if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$REGION" > /dev/null 2>&1; then
        echo "Updating existing Lambda function..."
        LAMBDA_FUN_ARN=$(aws lambda update-function-code \
            --function-name "$FUNCTION_NAME" \
            --image-uri "$ECR_URI" \
            --region "$REGION" \
            --query "FunctionArn" \
            --output text)
        echo "Lambda function updated (ARN: ${LAMBDA_FUN_ARN})"
    else
        ROLE_ARN=$(aws iam get-role --role-name "lambda-execution-role" --query "Role.Arn" --output text)
        echo "Creating new Lambda function..."
        LAMBDA_FUN_ARN=$(aws lambda create-function \
            --function-name "$FUNCTION_NAME" \
            --package-type "Image" \
            --code "ImageUri=$ECR_URI" \
            --role "$ROLE_ARN" \
            --timeout 60 \
            --memory-size 1024 \
            --region "$REGION" \
            --query "FunctionArn" \
            --output text)
        echo "Lambda function created (ARN: ${LAMBDA_FUN_ARN})"
    fi
}

cleanup() {
    echo "Cleaning up local build artifacts..."

    rm -rf chrome-bin chromedriver-bin
    echo "Deleted chrome-bin and chromedriver-bin directories."

    if docker images | grep -q "$ECR_REPO_NAME"; then
        docker rmi "$ECR_URI" --force || true
        echo "Removed local Docker image: $ECR_URI"
    fi

    docker system prune -f
    echo "Cleanup complete."
}

trap cleanup EXIT

# Run deployment steps
fetch_latest_chrome_and_driver
create_ecr_repo
build_and_push_docker
create_lambda_role
deploy_lambda

echo "Deployment of function (ARN: ${LAMBDA_FUN_ARN}) completed..."
