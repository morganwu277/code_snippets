# frontend keep clicking...
```js
setInterval( () => {
  document.querySelector('a[href="/en/slots"]').click();
  document.querySelector('a[href="/en/"]').click();
} , 10*1000)


```


# 不停测试网速
打开 `http://www.speedtest.cn/`       
Console里面输入:   
```
setInterval("(function(){jQuery('#myButton').click();})()",10*1000);
```
然后回车。



打开 `http://www.speedtest.com/`
Console里面输入:   

```
setInterval("(function(){jQuery('a[role=button]').click();})()",10*1000);
```
然后回车。
