#!/bin/bash

failures=()

for i in {1..100}; do
    echo "Running Jest test suite, iteration $i ..."

    jest_output=$(npm run test | tail -n +5)

    if echo "$jest_output" | jq -e '.testResults[].assertionResults[] | select(.status=="failed")' >/dev/null; then

        failing_tests=$(echo "$jest_output" | jq -r '.testResults[].assertionResults[] | select(.status=="failed") | .fullName')

        readarray -t failing_tests_collection <<<"$failing_tests"

        for i in "${failing_tests_collection[@]}"; do
            failures+=("$i")
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
