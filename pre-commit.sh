#!/usr/bin/env sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Program Name: pre-commit.sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script is a standard git hook. It is invoked each time when developer do `git commit' command.
#|                This script uses POSIX standards and should work with no errors in Unix as well as in
#|                other Unix-like OS'.
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script checks if commit for mistakes inside commit message and commited files
#|        1) This script checks if commit is initial
#|        2) It checks for whitespace errors
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

# Check if this is the initial commit
if git rev-parse --verify HEAD >/dev/null 2>&1
then
    echo "pre-commit: About to create a new commit..."
    against=HEAD
else
    echo "pre-commit: About to create the first commit..."
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# Use git diff-index to check for whitespace errors
echo "pre-commit: Testing for whitespace errors..."
if ! git diff-index --check --cached $against
then
    echo "pre-commit: Aborting commit due to whitespace errors"
    exit 1
else
    echo "pre-commit: No whitespace errors were detected"
    exit 0
fi

