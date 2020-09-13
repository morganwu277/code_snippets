TL;DR 

Most of ideas comes from https://apple.stackexchange.com/a/154180

1. compile next `click.m` file by using `gcc -o click click.m -framework ApplicationServices -framework Foundation`:

```c
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];

    int x = [args integerForKey:@"x"];
    int y = [args integerForKey:@"y"];

    CGPoint pt;
    pt.x = x;
    pt.y = y;

    CGPostMouseEvent( pt, 1, 1, 1 );
    CGPostMouseEvent( pt, 1, 1, 0 );

    [pool release];
    return 0;
}
```

Now you can open your terminal and run using next, eg: `click -x 100 -y 100`
```
click -x [coord] -y [coord]
```

2. open your terminal and run next `activate.sh` script

```bash
#!/bin/sh
while true; do ./click -x 100 -y 100; sleep 10; done
```

3. Sure if you can install external app, just use [Jiggler](https://github.com/bhaller/Jiggler)