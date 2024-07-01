#!/bin/bash

# File containing the list of filenames
input_file="hola.txt"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file $input_file not found!"
    exit 1
fi

# Read the input file line by line
while IFS= read -r filename; do
    # Create the file
    touch "$filename"
    echo "Created file: $filename"
done < "$input_file"

echo "All files created successfully."