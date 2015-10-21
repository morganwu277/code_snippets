## virt-manager on Mac OSX
```
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```
## get LISTEN connections
```
lsof -n -i4TCP:$PORT | grep LISTEN
```
