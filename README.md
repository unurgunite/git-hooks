# Git Hooks

This project is not updated yet and needs some improvements in code
semantics. If you able to help this project, fork it and make pull requests.

## Overview

1. `pre-commit`: run before `git commit` when you try to create a new commit.
2. `prepare-commit-msg`: executed before the editor is opened to write the commit message.
3. `commit-msg`: executed after you write a commit message and close the editor.
4. `post-commit`: executed immediately after the commit is created.
5. `pre-rebase`: run before the `git rebase` command when you start the rebase process.
6. `post-checkout`: executed after you change the current branch.
7. `post-merge`: executed after branches are merged.
8. `pre-push`: run before `git push` when you try to push changes to a remote repository.
