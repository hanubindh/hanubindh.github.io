#!/bin/sh

# Script to automate Python Lambda function setup for Selenium on Alpine (Default Docker Image)

set -e  # Exit on error
if [ -z "$AWS_KEY" ] || [ -z "$AWS_SECRET" ] || [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS_KEY, AWS_SECRET, and AWS_ACCOUNT_ID environment variables must be set."
    exit 1
fi

# Global Variables

# Default settings : Update if needed
FUNCTION_NAME="SelPy"
REGION="us-east-1"
RUNTIME="python3.13"

# Derived variables
LAYER_NAME="${FUNCTION_NAME}_layer"
ROLE_NAME="lambda-${FUNCTION_NAME}-role"
LAMBDA_POLICY_NAME="lambda-${FUNCTION_NAME}-policy"

RANDOM_STRING=$(tr -dc 'a-z' < /dev/urandom | head -c 8)
BUCKET_NAME="selpy-$RANDOM_STRING"


init_env() {
    set -e

    echo "Installing OS dependencies..."
    apk update && apk add --no-cache zip aws-cli

    echo "Installing Python..."
    rm -rf venv && python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    # pip install selenium webdriver_manager boto3
    pip install selenium webdriver_manager

    echo "Initializing AWS CLI..."
    (
        echo "${AWS_KEY}"
        echo "${AWS_SECRET}"
        echo "${REGION}"
        echo "json"
    ) | aws configure

    echo "Init completed!"
}

create_zips() {
    mkdir -p python
    cp lambda_function.py python/
    pip install -t python selenium webdriver_manager
    zip -r "${LAYER_NAME}.zip" python
    zip "${FUNCTION_NAME}.zip" lambda_function.py
}

create_s3_bucket() {
    echo "Creating S3 bucket: ${BUCKET_NAME}"
    aws s3 mb "s3://${BUCKET_NAME}" --region "$REGION"
    echo "Created S3 bucket: ${BUCKET_NAME}"
}

upload_to_s3() {
    echo "Layer upload to S3 started" 
    aws s3 cp "${LAYER_NAME}.zip" "s3://${BUCKET_NAME}/${LAYER_NAME}.zip"
    echo "Layer upload to S3 completed" 
    echo "Function upload to S3 started" 
    aws s3 cp "${FUNCTION_NAME}.zip" "s3://${BUCKET_NAME}/${FUNCTION_NAME}.zip"
    echo "Function upload to S3 completed" 
}

create_iam_role() {

    POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$LAMBDA_POLICY_NAME'].Arn" --output text)
    if [ -z "$POLICY_ARN" ]; then
        # Policy does not exist, create it
        echo "Policy '$LAMBDA_POLICY_NAME' does not exist. Creating..."

        POLICY_DOCUMENT=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/lambda/${FUNCTION_NAME}:*"
            ]
        }
    ]
}
EOF
        )
        

        POLICY_ARN=$(aws iam create-policy \
            --policy-name "$LAMBDA_POLICY_NAME" \
            --policy-document "${POLICY_DOCUMENT}" \
            --output text --query 'Policy.Arn')
        echo "Policy '$LAMBDA_POLICY_NAME' created with ARN: $POLICY_ARN"
    else
        # Policy exists
        echo "Policy '$LAMBDA_POLICY_NAME' already exists with ARN: $POLICY_ARN"
    fi

    echo "Creating IAM role..."
    
    if ! aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
        ROLE_ARN=$(
            aws iam create-role --role-name $ROLE_NAME \
            --assume-role-policy-document '{
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": { "Service": "lambda.amazonaws.com" },
                        "Action": "sts:AssumeRole"
                    }
                ]
            }' --output text --query 'Role.Arn')
        echo "Role created with ARN : ${ROLE_ARN}"
        
        #Attach the policy to the role.
        aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"

    fi

    export ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query "Role.Arn" --output text)
    echo "IAM Role ARN: $ROLE_ARN"
    sleep 10  # Allow time for IAM role propagation
}

deploy_lambda() {

    aws lambda publish-layer-version \
    --layer-name "$LAYER_NAME" \
    --content "S3Bucket=${BUCKET_NAME},S3Key=${LAYER_NAME}.zip" \
    --compatible-runtimes "$RUNTIME" \
    --region "$REGION"

    sleep 10

    LAYER_ARN=$(aws lambda list-layer-versions --layer-name "$LAYER_NAME" --query "LayerVersions[0].LayerVersionArn" --output text --region "$REGION")

    echo "The Layer ARN is ${LAYER_ARN}"

    aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --code "S3Bucket=${BUCKET_NAME},S3Key=${FUNCTION_NAME}.zip" \
    --handler lambda_function.lambda_handler \
    --role "$ROLE_ARN" \
    --layers "$LAYER_ARN" \
    --timeout 60 \
    --memory-size 1024 \
    --region "$REGION"
}

cleanup() {
    deactivate  # Deactivate the virtual environment
    rm -rf python "${LAYER_NAME}.zip" "${FUNCTION_NAME}.zip" venv
    aws s3 rb "s3://${BUCKET_NAME}" --force
}

trap cleanup EXIT

init_env
create_zips
create_s3_bucket
upload_to_s3
create_iam_role
deploy_lambda
echo "Setup complete."
