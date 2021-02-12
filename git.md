## git submodule update and delete
https://zhuanlan.zhihu.com/p/87053283

```sh
# sync url
git submodule sync --recursive
git submodule foreach "git fetch --prune || true"
git submodule update --init --force --recursive
# clean all non-git-managed files
git --work-tree=. clean -d --force

```


## use your own ssh keys for git
1. using ssh-git.sh
```
#!/bin/sh
if [ -z "$PKEY" ]; then
# if PKEY is not specified, run ssh using default keyfile
ssh "$@"
else
ssh -i "$PKEY" "$@"
fi
```
2. generate a ssh key and add that to your repo

3. using alias or just use this command 

`export GIT_SSH=~/ssh-git.sh && PKEY=~/this_is_my_ssh_key git pull/push/xxx/etc`


## HEAD,working tree, index, commit
- working tree: current working directory on your local disk.
- index: connecting working tree to commit, the cached/staged area.
- commit: only after commit, code will be in git repo
- HEAD: the most recent commit in current branch
Diff: 
- `git diff`: review diff between working tree and index
- `git diff --cached`: review diff between index and commit
- `git diff HEAD`: review diff between working tree and the most recent commit.

## Tips after reading <Pro Git> 
```bash
$ git diff 			# diff between working copy and cached area
$ git diff --staged/--cached	# diff in between cached area and HEAD
$ git format-patch HEAD^^^ # with three ^ tag, will create 3 patches...
$ git commit -a -m 'message' 	# just commit withouth adding files, if they are already being tracked

$ git rm -f <file> 				# delete file from OS and git repo
$ git rm --cached <file> 		# delete file from git but keep in OS 

$ git log -p -2					# show recent 2 commits diff, with pagenation style
$ git log --pretty=format:"%h - %an, %ad : %s" --graph # git log, oneline
$ git log --since=2.weeks		# show log with time trace
$ git log -Sfunction_name		# show log that the changes contains function_name string

$ git commit --amend			# use a new commit to override the last commit
								#### if there are no files changes, then just update commit msg
								#### if there are files changes, then update both commit msg and files
								#### but the result is the same: ONLY 1 COMMIT. 
$ git reset HEAD <file/folder> 	# reset HEAD and index of a file/folder, keep files changes in local (that means, off load changes from index area)
$ git reset HEAD --hard <file> 	# reset HEAD, index and working tree
$ git reset --hard HEAD~2       # remove last 2 local commits
$ git push --force				# after remove local commits, forcely push to remote ( so you will remove remote commit here )
$ git reset --hard <SOME-COMMIT> # 1. Make your current branch (typically master) back to point at <SOME-COMMIT>. 2. Then make the files in your working tree and the index ("staging area") the same as the versions committed in <SOME-COMMIT>.

$ git remote add upstream GIT_URL	# add a new remote 
$ git fetch --all 				# fetch all remote changes 
$ git remote show origin 		# show remote repo, eg. git remote show origin
$ git remote rename pb paul		# rename remote repo
$ git remote rm pb				# remove remote repo 
$ git tag -a v1.4 -m 'my version 1.4'	# create annotated(with GPG) tag 
$ git show v1.4					# show tag 
$ git tag -a v1.2 9fceb02		# tag using against a commit
$ git push origin v1.5			# push tags to origin repo
$ git push origin --tags		# push all tags to origin repo
$ git checkout -b v2_fix v2.0.0	# checkout branch of v2_fix from v2.0.0 tag
$ git filter-branch --tree-filter 'rm -f nodes/os/mac/jdk-8u191-macosx-x64.dmg' HEAD # remove a large object file 
$ git gc --prune=now --aggressive # clean large file object that committed but not able to be pushed to remote git server
```bash
(py_3.7) ➜  mac git:(master) ✗ git gc --prune=now --aggressive
Counting objects: 393, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (324/324), done.
Writing objects: 100% (393/393), done.
Total 393 (delta 173), reused 0 (delta 0)
```

## delete remote branch

Format of git ref is `<src>:<dst>`, leave <src> as empty, means `use empty to replace remote <dst>, which means delete <dst>`

```
$ git push origin :topic # delete remote topic ref(eg., branch/tag)
```

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

## oh-my-zsh slow on large git repo
https://gist.github.com/msabramo/2355834#gistcomment-2820263 

`git config --global --add oh-my-zsh.hide-dirty 1`
