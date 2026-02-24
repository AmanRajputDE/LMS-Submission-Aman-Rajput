# Create a File

text = '''Name, Age, Grade 
John, 20, A 
Alice, 19, B 
Mark, 21, A 
Sophie, 22, C'''

with open("students.txt",'w') as f:
    f.writelines(text)
