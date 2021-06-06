2020 Simple way :

git reset <commit_hash>
(The commit hash of the last commit you want to keep).

If the commit was pushed, you can then do :

git push -f
You will keep the now uncommitted changes locally