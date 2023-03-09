#!/bin/bash

source ./print_frequency_table.sh

# Default values
directory="."
save_outputs=false

# Parse options
while getopts ":d:h" opt; do
  case $opt in
  h)
    echo "Usage: $0 [-d directory] [-h]"
    echo "  -d: Specify the directory where the jest JSON files reside (default: current directory)"
    echo "  -h: Display this help message"
    exit
    ;;
  d)
    directory="$OPTARG"
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done

# Initialize failures array
failures=()

echo "$directory/*.json"

for file in "$directory"/*.json; do
  jest_output=$(cat "$file")

  if echo "$jest_output" | jq -e '.testResults[].assertionResults[] | select(.status=="failed")' >/dev/null; then

    failing_tests=$(echo "$jest_output" | jq -r '.testResults[].assertionResults[] | select(.status=="failed") | .fullName')

    readarray -t failing_tests_collection <<<"$failing_tests"

    for failure in "${failing_tests_collection[@]}"; do
      failures+=("$failure")
    done

  fi

done

print_frequency_table "${failures[@]}"
