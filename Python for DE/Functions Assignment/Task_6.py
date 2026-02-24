# Decorators
import time

def timer(func):
    def wrapper(n):
        start = time.time()
        func(n)
        end = time.time()
        print(end - start)
    return wrapper

@timer
def factorial(n):
    result = 1
    for i in range(1,n+1):
        result *= i

factorial(1000)