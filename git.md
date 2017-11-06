## ensure a linear history by preventing unnecessary merge commits when doing `git pull`
actually, with a --rebase option we can achieve this. 
```bash
git config --global branch.autosetuprebase always
```

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

## about those 'removes' in git
remove those files `git add` but not yet `git commit`,  simply removes a file from being tracked
```bash
git rm --cached <added_file_to_undo>
```
This simply continues to keep tracking changes to the file, but will place it back into the 'unstaged' area.
```bash
git reset HEAD [file]
```
This simply continues to keep tracking changes to the file, but will remove all the 'unstaged' changes.
```bash
git checkout [file]
```

## merge using theirs stragtegy 
```bash
$ git pull -X theirs
$ git merge -X theirs
$ git rebase -X theirs
```
## ignore white space changes
```bash
$ git diff --ignore-space-change
```
## use vimdiff as difftool
```bash
$ git config --global diff.tool vimdiff
$ git difftool
```
## remeber password locally
```bash
$ git config credential.helper store
```
https://git-scm.com/docs/git-credential-store 

## manage different users for github.com 
https://help.github.com/articles/connecting-to-github-with-ssh/     
`ssh -T git@github.com` works for each shell session. So for different session, using differnt `ssh-add` command in each shell window.     
Also remember to use next commands to manage user info for each project.        
```bash
git config user.name user1 
git config user.email email1@xxx.com 
```

