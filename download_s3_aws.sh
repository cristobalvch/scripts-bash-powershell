#!/bin/bash

# List all S3 buckets
bucket_names=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Directory to store S3 bucket contents
output_dir="s3_buckets"
mkdir -p $output_dir

# Loop through each bucket and download its contents
for bucket_name in $bucket_names; do
    echo "Downloading contents of S3 bucket: $bucket_name"
    
    # Create a directory for each bucket
    bucket_dir="${output_dir}/${bucket_name}"
    mkdir -p $bucket_dir
    
    # Download the bucket contents
    aws s3 sync s3://$bucket_name $bucket_dir
    
    echo "Contents of $bucket_name downloaded to $bucket_dir"
done
