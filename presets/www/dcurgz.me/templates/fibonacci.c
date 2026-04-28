// fibonacci.c: A C implementation of the Fibonacci function.
#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
    if (n < 2)
        return n;
    int i1 = 1, i2 = 0, tmp = 0;
    for (int i = 2; i < n; i++) {
        tmp = i1;
        i1 = i1 + i2;
        i2 = tmp;
    }
    return i1 + i2;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("A fibonacci implementation in C.\\n");
        printf("Computes fibonacci(n) for any given n.\\n");
        printf("Usage: %s <number>", argv[0]);
        exit(0);
    }
    int n = atoi(argv[1]);
    int result = fib(n);
    printf("%d", result);
}
