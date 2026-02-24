# Work with Large Files

def create_1_1000_file():
    with open('numbers.txt','w') as f:
        for i in range(1,1001):
            f.write(f"{i}\n")

with open('numbers.txt','r') as f:
    total = 0
    for line in f:
        total += int(line)

    print(total)
        