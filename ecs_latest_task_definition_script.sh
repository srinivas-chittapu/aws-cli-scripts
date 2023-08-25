#!/bin/bash

# Set your environment variables
export AWS_REGION="your-aws-region"
export ECS_FAMILY="your-ecs-task-family"

LOG_FILE="ecs_latest_task_definition_script.log"

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

# Describe latest task definition
log_message "Describing latest ECS task definition..."
latest_task_definition_json=$(run_aws_command aws ecs describe-task-definition --task-definition "$ECS_FAMILY:latest" --region "$AWS_REGION")
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved latest task definition"
    echo "Latest Task Definition JSON:"
    echo "$latest_task_definition_json"
else
    handle_error "Failed to describe latest task definition"
fi

log_message "Script execution completed successfully."
