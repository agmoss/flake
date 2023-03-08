for file in *.json; do

  jest_output=$(cat "$file")

  if echo "$jest_output" | jq -e '.testResults[].assertionResults[] | select(.status=="failed")' >/dev/null; then

    failing_tests=$(echo "$jest_output" | jq -r '.testResults[].assertionResults[] | select(.status=="failed") | .fullName')

    readarray -t failing_tests_collection <<<"$failing_tests"

    for failure in "${failing_tests_collection[@]}"; do
      failures+=("$failure")
    done

  fi

done

# Create frequency table

declare -A freq

for str in "${failures[@]}"; do
  ((freq["$str"]++))
done

# Print out the frequency table

max_len=0
for str in "${!freq[@]}"; do
  len=${#str}
  if ((len > max_len)); then
    max_len=$len
  fi
done

echo "$(tput bold)$(tput setaf 3)
               ___ _       ___             _
 ___ _____ ___|  _|_|___ _|  _|___ ___ ___|_|___ ___
|   |     | -_|  _| |   | |  _|  _|  _|  _| |   | -_|
|_|_|_|_|_|___|_| |_|_|_|_|_| |_| |_| |_| |_|_|_|___|
$(tput sgr0)"

printf "| $(tput bold)$(tput setaf 6)%-${max_len}s $(tput sgr0)| $(tput bold)$(tput setaf 6)%-10s $(tput sgr0)|\n" "String" "Frequency"
echo "$(tput bold)$(tput setaf 6)+$(printf '%*s' "$((max_len + 2))" "" | tr ' ' '-')+$(printf '%*s' 12 "" | tr ' ' '-')+$(tput sgr0)"
for str in "${!freq[@]}"; do
  printf "| $(tput setaf 2)%-${max_len}s $(tput sgr0)| $(tput setaf 5)%10d $(tput sgr0)|\n" "$str" "${freq[$str]}"
done
echo "$(tput bold)$(tput setaf 6)+$(printf '%*s' "$((max_len + 2))" "" | tr ' ' '-')+$(printf '%*s' 12 "" | tr ' ' '-')+$(tput sgr0)"
