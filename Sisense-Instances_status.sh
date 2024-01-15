#!/bin/bash

usage() {
    echo "Usage: $0 [-r <region>] [-i <instance_id>]"
    echo "Options:"
    echo "  -r <region>               Instances status in specific region"
    echo "  -i <instance_id>          Check status in specific instance by ID"
    echo "  -h                        Display this help message"
    exit 1
}

# Initializing variables
region=""
instance_id=""

while getopts "r:i:h" opt; do
    case $opt in
        r) region="$OPTARG" ;;
        i) instance_id="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Verifying AWS CLI existance and configuration
echo "Checking if AWS exist..."

if ! command -v aws ; then
    echo "AWS CLI is not installed, Please install it first https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

echo "Now checking if AWS CLI is configured..."

aws_access_key_id=$(aws configure get aws_access_key_id)
aws_secret_access_key=$(aws configure get aws_secret_access_key)

if [ -n "$aws_access_key_id" ] && [ -n "$aws_secret_access_key" ]; then
    echo "AWS access key and secret key is configured"
else
    echo "Please run 'aws configure' to set your access key and secret key"
    exit 1
fi

# Creating the AWS CLI command
aws_command="aws ec2 describe-instances"

if [ -n "$region" ]; then
    aws_command+=" --region $region"
fi

if [ -n "$instance_id" ]; then
    aws_command+=" --instance-ids $instance_id"
fi

# Execute the AWS CLI command
result=$(eval "$aws_command" 2>&1 | grep -E '"InstanceId"|"Name"')

if [ -z "$result" ]; then
    echo "No matching instances found."
else
    echo "Instances and their status:"
    echo "$result"
fi
