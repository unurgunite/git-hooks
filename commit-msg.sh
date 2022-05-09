#!/usr/bin/env sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Program Name: pre-commit.sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script is a standard git hook. It checks for syntax of commited files and runs RuboCop to
#|                improve it. This script uses POSIX standards and should work with no errors in Unix as well as in
#|                other Unix-like OS'.
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script checks for syntax of commited files
#|        1) It runs RuboCop and checks for any errors
#|
#| Note:
#|        a) This script takes arguments in Unix98-standard
#|
#|-----------------------------------------------------------------------------------------------------------------|
#| Author: unurgunite
#| Date: 2022/09/05
#|-----------------------------------------------------------------------------------------------------------------|
#| License: MIT
#|-----------------------------------------------------------------------------------------------------------------|

