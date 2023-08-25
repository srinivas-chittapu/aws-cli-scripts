#!/bin/bash

# Set your environment variables
export SECRET_NAME="your-secret-name"
export AWS_REGION="your-aws-region"

LOG_FILE="aws_secret_manager_script.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to log success
log_success() {
    log_message "SUCCESS: $1"
}

# Function to handle errors
handle_error() {
    log_message "Error: $1"
    exit 1
}

# Function to handle errors gracefully
handle_error_gracefully() {
    log_message "Error: $1"
    return 1
}

# Try-catch block for AWS CLI commands
run_aws_command() {
    "$@" 2>> "$LOG_FILE" || handle_error_gracefully "Failed to execute: $*"
}

# Get the value of a secret
log_message "Getting secret value..."
secret_value=$(run_aws_command aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$AWS_REGION" --query SecretString --output text)
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved secret value"
    echo "Secret Value:"
    echo "$secret_value"
else
    handle_error "Failed to get secret value"
fi

# Get the complete secret JSON (including metadata)
log_message "Getting secret JSON..."
secret_json=$(run_aws_command aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$AWS_REGION" --query SecretBinary --output text | base64 --decode)
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved secret JSON"
    echo "Secret JSON:"
    echo "$secret_json"
else
    handle_error "Failed to get secret JSON"
fi

# List all secrets
log_message "Listing all secrets..."
secrets_list=$(run_aws_command aws secretsmanager list-secrets --region "$AWS_REGION")
if [ $? -eq 0 ]; then
    log_success "Successfully listed secrets"
    echo "List of Secrets:"
    echo "$secrets_list"
else
    handle_error "Failed to list secrets"
fi

# List all versions of a secret
log_message "Listing all versions of a secret..."
secret_versions=$(run_aws_command aws secretsmanager list-secret-versions --secret-id "$SECRET_NAME" --region "$AWS_REGION")
if [ $? -eq 0 ]; then
    log_success "Successfully listed secret versions"
    echo "List of Secret Versions:"
    echo "$secret_versions"
else
    handle_error "Failed to list secret versions"
fi

# Get secret metadata
log_message "Getting secret metadata..."
secret_metadata=$(run_aws_command aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --region "$AWS_REGION")
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved secret metadata"
    echo "Secret Metadata:"
    echo "$secret_metadata"
else
    handle_error "Failed to get secret metadata"
fi

log_message "Script execution completed successfully."
