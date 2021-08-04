# upgrade/downgrade to version

1. download ipsw from https://ipsw.me/device-finder 
2. enter into DFU mode for your iPhone ( before that, needs to connect to macOS and trust the device )
3. `[Option]` + Recover... and then select the previous ipsw

if you are downloading an old Unsigned IPSW, please choose https://github.com/MatthewPierson/Vieux with python 3.6 environment ( @2021-Aug-4 doesn't support Python 3.9 ) 
Python 3.9 removed `fromstring()` in `array.array` https://docs.python.org/3/whatsnew/3.9.html#removed 

