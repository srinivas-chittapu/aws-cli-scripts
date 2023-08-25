#!/bin/bash

# Set your environment variables
export AWS_REGION="your-aws-region"
export ECS_CLUSTER="your-ecs-cluster-name"

LOG_FILE="ecs_task_retrieval_script.log"

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

# Describe running tasks
log_message "Describing running ECS tasks..."
running_tasks_json=$(run_aws_command aws ecs list-tasks --cluster "$ECS_CLUSTER" --desired-status RUNNING --region "$AWS_REGION")
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved running tasks"
    echo "Running Tasks JSON:"
    echo "$running_tasks_json"
else
    handle_error "Failed to describe running tasks"
fi

log_message "Script execution completed successfully."
