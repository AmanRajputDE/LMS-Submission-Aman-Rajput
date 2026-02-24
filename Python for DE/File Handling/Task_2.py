# Read the File

with open('students.txt','r') as f:
    for line in f:
        print(line,end="")