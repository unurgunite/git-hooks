#!/usr/bin/env sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Program Name: commit-msg.sh
#|-----------------------------------------------------------------------------------------------------------------|
#| Description: This script is a standard git hook. It changes commit message according to local standards. This 
#|                script uses POSIX standards and should work with no errors in Unix as well as in
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

./commit-msg.rb

start_with_verb(message) {
	echo 'Analyzing message...'
	case $message in
		Added*|\
		Created*|\
		Fixed*|\
		Updated*|\
		Reworked*|\
		Removed*)
			echo 'Done!'
			return 0
			;;
		*)
			echo "The commit message should start with one of this words or with verb in past simple tense"
			return 1
			;;
	esac
}

change_commit() {
	file="$1"
	sed -i.bak -e "1s/.*/#$ticket_id $ticket_title/" "$file"
}

