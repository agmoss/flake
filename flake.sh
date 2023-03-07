#!/bin/bash

failures=()

echo "jest test script: $1"
echo "number of iterations: $2"

for ((i = 1; i <= $2; i++)); do
    echo "Running Jest test suite, iteration $i ..."

    output_file="test_results_$i.json"

    jest_output=$($1 | tail -n +5)

    # TODO Expose this functionality in the api
    echo "$jest_output" >$output_file

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

echo -e "String\tFrequency"
for str in "${!freq[@]}"; do
    echo -e "$str\t${freq[$str]}"
done
