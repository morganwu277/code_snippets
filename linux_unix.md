### Control Groups, Resource Management
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/resource_management_guide/chap-introduction_to_control_groups 

### pipe how to use
Here is pipe diagram:
![Pipe](http://tldp.org/LDP/lpg/img4.gif "Pipe")    
[About Pipes in Linux](http://tldp.org/LDP/lpg/node10.html#SECTION00721000000000000000)    

*Example below, diagram!*    
![Pipe](http://tldp.org/LDP/lpg/img6.gif "Read Data from Child Process")     
**Please remember: data flows from pipe[1] to pipe[0] and will flow through the kernel, so we need to do some close actions.**    
Example code (read output from child process) :     
```cpp
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
Here is a better and more detailed example: http://www.cs.loyola.edu/~jglenn/702/S2005/Examples/dup2.html 

### Pipe, a more interesting example
```bash
/*
* 
* Another requirement:
* // a.stdout -> b.stdin
* // b.stdout -> a.stdin
*/
int pipe_fd1[2]; 
int pipe_fd2[2]; 
pipe(pipe_fd1);
pipe(pipe_fd2);

while ((pid_a = fork()) < 0);

if (pid_a == 0) { 
  close(pipe_fd1[0]);
  dup2(pipe_fd1[1], 1);  // replace stdout with pipe_fd1
                         // a.stdout -> a.pipe_fd2[1] 
                         //          -> b.pipe_fd2[0] -> b.stdin

  close(pipe_fd2[1]);
  dup2(pipe_fd2[0], 0);  // replace stdin with pipe_fd2
                         // a.pipe_fd2[0] -> a.stdin

  execvp(a);
}
while ((pid_b = fork()) < 0);

if (pid_b == 0) { 
  close(pipe_fd1[1]);
  dup2(pipe_fd1[0], 0);  // replace stdin with pipe_fd1
                         // b.pipe_fd1[0] -> b.stdin 

  close(pipe_fd2[0]);
  dup2(pipe_fd2[1], 1);  // replace stdout with pipe_fd2
                         // b.stdout -> b.pipe_fd2[1] 
                         //          -> a.pipe_fd2[0] -> a.stdin

  execvp(b); 
}
```
