#!/bin/bash

# Set your environment variables
export AWS_REGION="your-aws-region"
export LOG_GROUP_NAME="your-log-group-name"

LOG_FILE="cloudwatch_latest_stream_script.log"

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

# Get the latest log stream
log_message "Getting latest log stream in $LOG_GROUP_NAME..."
latest_log_stream=$(run_aws_command aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --order-by LastEventTime --descending --max-items 1 --region "$AWS_REGION" --query 'logStreams[0].logStreamName' --output text)
if [ $? -eq 0 ]; then
    log_success "Successfully retrieved latest log stream"
    echo "Latest Log Stream:"
    echo "$latest_log_stream"
else
    handle_error "Failed to get latest log stream"
fi

log_message "Script execution completed successfully."
