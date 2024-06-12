#!/bin/bash

# List all Lambda functions
function_names=$(aws lambda list-functions --query 'Functions[*].FunctionName' --output text)

# Directory to store Lambda functions
output_dir="lambda_functions"
mkdir -p $output_dir

# Loop through each function and download its code
for function_name in $function_names; do
    echo "Downloading code for Lambda function: $function_name"
    
    # Get the function code URL
    code_url=$(aws lambda get-function --function-name $function_name --query 'Code.Location' --output text)
    
    # Download the code
    output_file="${output_dir}/${function_name}.zip"
    curl -o $output_file $code_url
    
    echo "Code for $function_name downloaded to $output_file"
done
