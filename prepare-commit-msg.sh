#!/usr/bin/env sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Program Name: prepare-commit-msg.sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script is a standard git hook. It checks for mistakes inside commit message.
#|                This script uses POSIX standards and should work with no errors in Unix as well as in 
#|                other Unix-like OS'.
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script checks for mistakes inside commit message and commited files
#|        1) This script checks for mistakes inside commit message
#|        2) It gives a choice if any of errors were found
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


