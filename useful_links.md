## LVS
* http://www.linuxvirtualserver.org/zh/lvs1.html
* http://www.linuxvirtualserver.org/zh/lvs2.html 
* http://www.linuxvirtualserver.org/zh/lvs3.html  
* http://www.linuxvirtualserver.org/zh/lvs4.html 
* http://itlab.idcquan.com/linux/special/Linuxjq/index.html 
* http://zh.linuxvirtualserver.org/ 
* LVS+HAProxy http://www.open-open.com/lib/view/open1421910195828.html 
* Nginx VS. LVS. http://www.ha97.com/5646.html 

## Nginx 
* http://itlab.idcquan.com/Web/Special/Nginx/ 


## record screen with sound using QuickTimePlayer in macOS

basic idea:
1. output audio into a device
2. select that device into QuickTimePlayer's microphone

TLDR;
1. install this software  https://github.com/mattingalls/Soundflower/releases/tag/2.0b2 remember to set the security settings 
2. open midi settings, add Aggregate Device, select `soundflower 2ch` + `macbook pro microphone`
3. and then add Multi-Output Device, select `soundflower 2ch` + `macbook pro speakers`
4. open QuickTimePlayer, record, and select all screen, and ensure, sound source comes from `Aggregate Device` 
5. that's it


steps as example of recording Zoom
1. install this software  https://github.com/mattingalls/Soundflower/releases/tag/2.0b2 remember to set the security settings 
2. and then, for example, you need to record zoom, need to set zoom's output audio into `Soundflower(2ch)` device
3. and then in QuickTimePlayer record settings, select above `Soundflower(2ch)` device as input microphone.
