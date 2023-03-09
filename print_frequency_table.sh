#!/bin/bash

print_frequency_table() {
  declare -A freq
  for str in "${@}"; do
    ((freq["$str"]++))
  done

  max_len=0
  for str in "${!freq[@]}"; do
    len=${#str}
    if ((len > max_len)); then
      max_len=$len
    fi
  done

  printf "| $(tput bold)$(tput setaf 6)%-${max_len}s $(tput sgr0)| $(tput bold)$(tput setaf 6)%-10s $(tput sgr0)|\n" "String" "Frequency"
  echo "$(tput bold)$(tput setaf 6)+$(printf '%*s' "$((max_len + 2))" "" | tr ' ' '-')+$(printf '%*s' 12 "" | tr ' ' '-')+$(tput sgr0)"
  for str in "${!freq[@]}"; do
    printf "| $(tput setaf 2)%-${max_len}s $(tput sgr0)| $(tput setaf 5)%10d $(tput sgr0)|\n" "$str" "${freq[$str]}"
  done
  echo "$(tput bold)$(tput setaf 6)+$(printf '%*s' "$((max_len + 2))" "" | tr ' ' '-')+$(printf '%*s' 12 "" | tr ' ' '-')+$(tput sgr0)"
}
