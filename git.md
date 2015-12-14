# delete remote tag && remote branch
```bash
# show local tags
git tag 
Remote_Systems_Operation
# delete local tags 
git tag -d Remote_Systems_Operation 
# delete remote tag by push
git push origin :refs/tags/Remote_Systems_Operation

# delete local branch
git branch -r -d origin/branch-name
# delete remote branch by push
git push origin :branch-name
```

## remove those files `git add` but not yet `git commit`
```bash
git rm --cached <added_file_to_undo>
```
