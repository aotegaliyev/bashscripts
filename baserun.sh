#!/bin/bash

BASE_DIR=~/code
FILE_DIR=$BASE_DIR/services.txt

if [ ! -f "$FILE_DIR" ]; then
    echo "Error: The services.txt file does not exist."
    exit 1
fi

declare -a pids=()

while IFS= read -r line; do
    # Remove leading and trailing whitespace
    line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [ -z "$line" ] || [[ $line == \#* ]]; then
        continue
    fi

    project_dir="$BASE_DIR/$line"

    if [ ! -d "$project_dir" ]; then
        echo "Error: Directory not found - $project_dir"
        continue
    fi

    if [ ! -f "$project_dir/docker-compose.yml" ]; then
        echo "Error: docker-compose.yml not found in $project_dir"
        continue
    fi

    (cd "$project_dir" && docker-compose up -d) &
    pids+=($!)
    
done < "$FILE_DIR"

# Wait for all background processes to complete
for pid in "${pids[@]}"; do
    wait "$pid"
done
