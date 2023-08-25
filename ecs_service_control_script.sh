#!/bin/bash

# Set your environment variables
export AWS_REGION="your-aws-region"
export ECS_CLUSTER="your-ecs-cluster"
export ECS_SERVICE="your-ecs-service"

LOG_FILE="ecs_service_control_script.log"

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

# Start or stop ECS service
service_action() {
    local action="$1"
    local count="$2"

    log_message "$action ECS service..."
    run_aws_command aws ecs "$action"-service --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE" --region "$AWS_REGION" --desired-count "$count"
    if [ $? -eq 0 ]; then
        log_success "Successfully $action ECS service"
    else
        handle_error "Failed to $action ECS service"
    fi
}

# Parse command line arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <start|stop> <desired-task-count>"
    exit 1
fi

ACTION="$1"
DESIRED_COUNT="$2"

if [ "$ACTION" != "start" ] && [ "$ACTION" != "stop" ]; then
    echo "Invalid action: $ACTION. Use 'start' or 'stop'."
    exit 1
fi

# Perform action on ECS service
service_action "$ACTION" "$DESIRED_COUNT"

log_message "Script execution completed successfully."
