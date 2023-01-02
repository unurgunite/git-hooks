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

# Check that the file is saved in UTF-8 encoding
if ! file --mime-encoding "$1" | grep -q 'utf-8'; then
  echo "Error: File $1 is not saved in UTF-8 encoding"
  exit 1
fi

# Remove BOM and carriage return
sed -i '' -e 's/^\xEF\xBB\xBF//' "$1"
sed -i '' -e 's/\r$//' "$1"

# Run rubocop to detect and automatically fix errors in the code
bundle exec rubocop --auto-correct "$1"
