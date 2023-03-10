#!/bin/bash

# Default values
jest_script="npm run test -- --json"
iterations=100
save_outputs=false
directory="."

# Parse options
while getopts ":s:i:d:jh" opt; do
  case $opt in
  h)
    echo "Usage: $0 [-s jest_script] [-i iterations] [-j] [-h]"
    echo "  -s: Specify the jest test script (default: npm run test -- --json)"
    echo "  -i: Specify the number of test iterations (default: 100)"
    echo "  -j: Save jest --json outputs (default: false)"
    echo "  -d: Specify the directory to run the test script (default: current directory)"
    echo "  -h: Display this help message"
    exit 0
    ;;
  s)
    jest_script="$OPTARG"
    ;;
  i)
    iterations="$OPTARG"
    ;;
  j)
    save_outputs=true
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

failures=()

echo "jest test script: $jest_script"
echo "number of iterations: $iterations"
echo "running test command in: $directory"
echo "saving jest --json files: $save_outputs"

# Run test suite and collect failures

cd $directory

for ((i = 1; i <= $iterations; i++)); do
  echo "Running Jest test suite, iteration $i ..."

  jest_output=$($jest_script | tail -n +5)

  if [ "$save_outputs" = true ]; then
    output_file="test_results_$i.json"
    echo "$jest_output" >$output_file
  fi

  if echo "$jest_output" | jq -e '.testResults[].assertionResults[] | select(.status=="failed")' >/dev/null; then

    failing_tests=$(echo "$jest_output" | jq -r '.testResults[].assertionResults[] | select(.status=="failed") | .fullName')

    readarray -t failing_tests_collection <<<"$failing_tests"

    for failure in "${failing_tests_collection[@]}"; do
      failures+=("$failure")
    done

  fi
done

declare -A freq

for str in "${failures[@]}"; do
  ((freq["$str"]++))
done

# Print out the frequency table (simple)
echo -e "String\tFrequency"
for str in "${!freq[@]}"; do
  echo -e "$str\t${freq[$str]}"
done
