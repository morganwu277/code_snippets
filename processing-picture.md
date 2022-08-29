# crop pictures with batch script

In macOS we use , command + Shift + 3 to get a screenshot, however we may also need to crop the specific areas.

```
#!/bin/bash
# dependencies: 
#   brew install imagemagick
#
# crop params: width height left top
# then you could do it with (widthxheight+left+top / wxh+l+t format):
# from: https://askubuntu.com/a/631695
IFS=$'\n';for pic in `ls Screen*png|grep '2022-08-29'`;do 
  newpic="crop-$pic"
  convert "$pic" -crop 1100x1850+1225+218 $newpic
done
```
