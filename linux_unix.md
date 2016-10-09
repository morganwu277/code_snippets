### pipe how to use
Here is pipe diagram:
![Pipe](http://tldp.org/LDP/lpg/img4.gif "Pipe")    
[About Pipes in Linux](http://tldp.org/LDP/lpg/node10.html#SECTION00721000000000000000)
**Please remember: data flows from pipe[1] to pipe[0] and will flow through the kernel, so we need to do some close actions.**    
Example code (read output from child process) :     
```c
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>


int main(int argc, char *argv[]) {
    int fds[2]; // write pipe(child->parent)
    pipe(fds);
    int pid = fork();
    if (pid < 0) {
        printf("Fail for new process!\n");
    } else if (pid == 0) { // child process
        close(fds[0]); // close input side of pipe
        dup2(fds[1], STDOUT_FILENO);

        char MSG[4096];
        sprintf(MSG, "Hello world1\nHello world2\n");
        write(fds[1], MSG, strlen(MSG)); // output to pipe, i.e. to parent process's pipe
        _exit(0);
    } else {
        close(fds[1]); // close output side of pipe
        wait(NULL);

        char MSG[4096];
        read(fds[0], MSG, 4096); // read from the pipe, i.e. read from child process's output
        printf("%s", MSG);
    }
    return 0;
}
```
