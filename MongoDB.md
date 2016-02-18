Opeartions about MongoDB   
===
OS: Mac OSX, for other system, please view docs in official website.

## 1. Installing the MongoDB by `brew`
About [brew](http://brew.sh/)   
Here are the easy steps:
```bash
$ # install the mongodb
$ brew update && brew install mongodb

$ # initialize the data dir
$ sudo mkdir -p /data/db
$ sudo chown `id -u` /data/db

$ # start the mongodb process
$ mongod
```
if all goes right, then you'll see lines like below scrolling down your terminal:
```bash
2016-02-12T13:44:21.038-0500 I CONTROL  [initandlisten] MongoDB starting : pid=3862 port=27017 dbpath=/data/db 64-bit host=morgan-yinnut.local
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] db version v3.2.1
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] git version: a14d55980c2cdc565d4704a7e3ad37e4e535c1b2
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] allocator: system
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] modules: none
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] build environment:
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten]     distarch: x86_64
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten]     target_arch: x86_64
2016-02-12T13:44:21.039-0500 I CONTROL  [initandlisten] options: {}
2016-02-12T13:44:21.040-0500 I STORAGE  [initandlisten] wiredtiger_open config: create,cache_size=9G,session_max=20000,eviction=(threads_max=4),config_base=false,statistics=(fast),log=(enabled=true,archive=true,path=journal,compressor=snappy),file_manager=(close_idle_time=100000),checkpoint=(wait=60,log_size=2GB),statistics_log=(wait=0),
2016-02-12T13:44:21.304-0500 I CONTROL  [initandlisten] 
2016-02-12T13:44:21.304-0500 I CONTROL  [initandlisten] ** WARNING: soft rlimits too low. Number of files is 256, should be at least 1000
2016-02-12T13:44:21.304-0500 I FTDC     [initandlisten] Initializing full-time diagnostic data capture with directory '/data/db/diagnostic.data'
2016-02-12T13:44:21.304-0500 I NETWORK  [HostnameCanonicalizationWorker] Starting hostname canonicalization worker
2016-02-12T13:44:21.342-0500 I NETWORK  [initandlisten] waiting for connections on port 27017
```
