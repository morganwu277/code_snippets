## small python tricks
1. `sys.argv[1]` means 1st parameter string format

2. sort dict

```py
# sort by keys
dict(sorted(svc_failed_records.items()))
# sort by values
dict(sorted(svc_failed_records.items(), key=lambda item: item[1]))
```

3. regex usage
```py
m = re.search(".+_(\d+)_days.+", retention_value_str)
return m.group(1) if m != None else -1
```

4. lambda usage
```py
# filter out all items which template_json[x]['settings']['index']['lifecycle']['name'] contains 'days'
retention_days_keys = list(
    filter(lambda x: 'settings' in template_json[x] and
                     'index' in template_json[x]['settings'] != None and
                     'lifecycle' in template_json[x]['settings']['index'] != None and
                     'name' in template_json[x]['settings']['index']['lifecycle'] != None and
                     'days' in template_json[x]['settings']['index']['lifecycle']['name'],
           template_json.keys())
)
# and then pickup the specific template_json[x]['settings']['index']['lifecycle']['name'] out as a new dict
retention_days_items = dict((k, extract_days_from_retention_value_str(template_json[k]['settings']['index']['lifecycle']['name'])) for k in retention_days_keys)
# or we can use next to construct new dict
retention_days_items = dict(map(lambda k: (k, extract_days_from_retention_value_str(template_json[k]['settings']['index']['lifecycle']['name'])), retention_days_keys))
```

5. construct new data from existing, which is basically the same as
```py
# next two statements have same effect
new_dict = dict((k,my_dict[k]) for k in my_key_list)
new_dict = dict(map(lbmda k: (k,my_dict[k]), my_key_list))

# construct from list
new_list = [i**2 for i in range(1, 20)]
```

6. send html email
```py
def send_email(subject='test sub',
               from_user='abc@def.com',
               to_list='abc@def.com',
               email_html_content='',
               smtp='labmailer.your.company.com'):
    import smtplib

    from email.mime.multipart import MIMEMultipart
    from email.mime.text import MIMEText

    # me == my email address
    # you == recipient's email address
    me = from_user
    you = to_list

    # Create message container - the correct MIME type is multipart/alternative.
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = me
    msg['To'] = you

    # Create the body of the message (a plain-text and an HTML version).
    text = "Hi!\nHow are you?\nHere is the link you wanted:\nhttps://www.python.org"

    # Record the MIME types of both parts - text/plain and text/html.
    part1 = MIMEText(text, 'plain')
    part2 = MIMEText(email_html_content, 'html')

    # Attach parts into message container.
    # According to RFC 2046, the last part of a multipart message, in this case
    # the HTML message, is best and preferred.
    msg.attach(part1)
    msg.attach(part2)

    # Send the message via local SMTP server.
    s = smtplib.SMTP(smtp)
    # sendmail function takes 3 arguments: sender's address, recipient's address
    # and message to send - here it is sent as one string.
    s.sendmail(me, you, msg.as_string())
    s.quit()
```

7. python decorators
https://python3-cookbook.readthedocs.io/zh_CN/latest/c09/p02_preserve_function_metadata_when_write_decorators.html#id3

    Using decorators we can achieve the same effect as Java Annotations. The secret is to use `@wraps` in `functools` library.
```py
from functools import wraps
def timethis(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        # xxxx your customized code
        result = func(*args, **kwargs)
        # yyyy your customized code
        print(func.__name__) # here we print the func name
        return result
    return wrapper
```
```py

# defines @timethis decorator
import time
from functools import wraps
def timethis(func):
    '''
    Decorator that reports the execution time.
    '''
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(func.__name__, end-start) # here we print the func name and execution time
        return result
    return wrapper


# use @timethis decorator
>>> @timethis
... def countdown(n):
...     '''
...     Counts down
...     '''
...     while n > 0:
...         n -= 1
...
>>> countdown(100000)
countdown 0.008917808532714844
>>> countdown.__name__
'countdown'
>>> countdown.__doc__
'\n\tCounts down\n\t'
>>> countdown.__annotations__
{'n': <class 'int'>}
>>>
```



## python logging facilities
More python attributes to be outputed:  https://docs.python.org/3/library/logging.html#logrecord-attributes

```py
LOG = logging.getLogger('sae')
LOG.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - {%(filename)s:%(lineno)d} - %(levelname)s - %(message)s')
fh = logging.FileHandler("data-import.log", delay=True)
fh.setLevel(logging.DEBUG)
fh.setFormatter(formatter)
# create console handler and set level to debug
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
ch.setFormatter(formatter)
# add ch to logger
LOG.addHandler(ch)
LOG.addHandler(fh)
```

## call CPP library from python
Mock.cpp, you need to expose by using `extern "C"`
```cpp
#include <string>
#include <stdio.h>
#include <stdlib.h>
using namespace std;

extern "C" {
    int addVertex(int type, string label);
    int addEdge(int vertex1, int vertex2, int directional, double speed, double length);
    void edgeEvent(int edge, int eventType);
    bool road(int *edges);
    string *trip(int fromVertex, int toVertex);
    int vertex(string point);
}

 int addVertex(int type, string label) {
    return 1;
}

 int addEdge(int vertex1, int vertex2, int directional, double speed, double length) {
    return 2;
}

 void edgeEvent(int edge, int eventType) {
    printf("Edge is %d , eventType is %d", edge, eventType);
}

 bool road(int *edges) {
    return true;
}

 string *trip(int fromVertex, int toVertex) {
    string *str =(string*)malloc(3* sizeof(string));
    return str;
}

 int vertex(string point) {
    return 3;
}
```
Build library by using `g++ Mock.cpp -fPIC -shared -o libMock.so`

test.py, you need load different library 
```py
#!/bin/python
from ctypes import cdll
stdc=cdll.LoadLibrary("libc.so.6")
stdcpp=cdll.LoadLibrary("libstdc++.so.6")
lib = cdll.LoadLibrary("./libMock.so")
vertextType = ["Point of interest", "intersection"]
a = lib.addVertex(1, "V1")
print(a)
```

## call C library from python
same as above, the only difference is that when building library, you need to use `gcc` instead of `g++`

1. write hello.c & hello.h

2. compile with `gcc hello.c -fPIC -shared -o libhello.so`

3. in python use 

    ```python 
    from ctypes import cdll
    
    lib=cdll.LoadLibrary("./libhello.so")
    lib.hello('Amy')
    ```

## multi thread
```python
import threading

threads = []
x = threading.Thread(target=insert_row, args=(conn, r)) # conn and r are params for insert_row function
x.start()
threads.append(x)

# wait for finish
for x in threads:
  x.join()
```

## thread pool executor
```python
import concurrent.futures

futures = []
with concurrent.futures.ThreadPoolExecutor(max_workers=40) as executor:
  f = executor.submit(insert_row, conn, r) # conn and r are params for insert_row function
  futures.append(f)

# wait for finish
for x in futures:
  x.result()
```
