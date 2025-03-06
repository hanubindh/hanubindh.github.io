#!/bin/bash


# Variables
FUNCTION_NAME="SelPy"
IMAGE_NAME="${FUNCTION_NAME}-lambda-img"
DOCKERFILE_PATH="Dockerfile"
LAMBDA_ZIP="lambda.zip"
REGION="us-east-1"

# Get latest stable Chrome version
CHROME_VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)
CHROME_DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE_CHROMEDRIVER")

echo "Chrome Version: $CHROME_VERSION"
echo "ChromeDriver Version: $CHROME_DRIVER_VERSION"

init_env() {

}
# Dockerfile
touch Dockerfile
cat <<EOF > Dockerfile
FROM public.ecr.aws/lambda/python:3.9

# Install dependencies
RUN yum install -y unzip zip chromium which

# Download and install Chrome
ARG CHROME_VERSION
RUN curl -Ls "https://edgedl.me.gcr.io/edgedl/chrome/chrome-for-testing/\${CHROME_VERSION}/linux64/chrome-linux64.zip" -o chrome.zip && \
    unzip chrome.zip && \
    mv chrome-linux64 /opt/chrome && \
    rm chrome.zip && \
    chmod +x /opt/chrome/chrome

# Download and install ChromeDriver
ARG CHROME_DRIVER_VERSION
RUN curl -Ls "https://edgedl.me.gcr.io/edgedl/chrome/chrome-for-testing/\${CHROME_DRIVER_VERSION}/linux64/chromedriver-linux64.zip" -o chromedriver.zip && \
    unzip chromedriver.zip && \
    mv chromedriver-linux64/chromedriver /opt/chromedriver && \
    rm chromedriver.zip && \
    chmod +x /opt/chromedriver/chromedriver

# Copy function code
COPY lambda_function.py ./

# Install Selenium
RUN pip install --no-cache-dir selenium==4.12.0

# Set handler
CMD [ "lambda_function.lambda_handler" ]
EOF

# Build Docker image
docker build --build-arg CHROME_VERSION="$CHROME_VERSION" --build-arg CHROME_DRIVER_VERSION="$CHROME_DRIVER_VERSION" -t $IMAGE_NAME .

# Tag and push to ECR
docker tag $IMAGE_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
aws ecr create-repository --repository-name $IMAGE_NAME --region $REGION || true
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest

# Create Lambda function or update if it exists
aws lambda create-function \
    --function-name $FUNCTION_NAME \
    --package-type Image \
    --code ImageUri=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest \
    --role arn:aws:iam::$ACCOUNT_ID:role/service-role/lambda_basic_execution \
    --timeout 30 \
    --memory-size 1024 \
    --region $REGION || aws lambda update-function-code --function-name $FUNCTION_NAME --image-uri $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:latest --region $REGION

echo "Lambda function deployed or updated."