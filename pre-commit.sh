#!/usr/bin/env sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Program Name: pre-commit.sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script is a standard git hook. It is invoked each time when developer do `git commit' command.
#|                This script uses POSIX standards and should work with no errors in Unix as well as in
#|                other Unix-like OS'.
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script checks if commit for mistakes inside commit message and commited files
#|        1) This script checks if file saved in UTF-8
#|        2) It removes BOM and carriage return
#|        3) It runs rubocop
#|
#| Note:
#|        a) This script does not take any arguments
#|
#|-----------------------------------------------------------------------------------------------------------------|
#| Author: unurgunite
#| Date: 2022/10/05
#|-----------------------------------------------------------------------------------------------------------------|
#| License: MIT
#|-----------------------------------------------------------------------------------------------------------------|

# Check that all staged files are saved in UTF-8 encoding
for file in $(git diff --cached --name-only); do
  sed -e 's/^\xEF\xBB\xBF//' "$file"
  sed -e 's/\r$//' "$file"
  encoding=$(file --mime-encoding -b "$file")
  if [ "$encoding" != "utf-8" ] && [ "$encoding" != "us-ascii" ]; then
    echo "Error: File $file is not encoded in UTF-8 or US-ASCII"
    exit 1
  fi
done

# Get only added or modified Ruby files
changed_files=$(git status --porcelain | awk -F ' ' '$1 ~ /A|AM|^M/ {print $2}' | grep "\.rb$" | tr '\n' ' ')

if [ -n "$changed_files" ]; then
  # Run rubocop to detect and automatically fix errors in the code
  bundle exec rubocop --autocorrect --require rubocop-performance "$changed_files"
  exit $?
fi

exit 0
