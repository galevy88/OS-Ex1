#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Not enough parameters"
  exit 1
fi

if [ $# -eq 3 ] && [ $3 = "-r" ]; then
  recursive=true
else
  recursive=false
fi

dir_path=$1
word_to_find=$2

if [ $recursive = true ]; then
  find "$dir_path" -type f -name "*.out" -delete
  find "$dir_path" -type f -name "*.c" -exec sh -c 'grep -Eqi "\<'"$word_to_find"'[.!?,]?\>" "$0" && gcc -w -o "${0%.c}.out" "$0"' {} \;
else
  cd "$dir_path"
  rm -f *.out
  for c_file in *.c; do
    if grep -Eqi "\<$word_to_find[.!?,]?\>" "$c_file"; then
      gcc -w -o "${c_file%.c}.out" "$c_file"
      [[ -e "${c_file%.c}.out" ]]
    fi
  done
fi
