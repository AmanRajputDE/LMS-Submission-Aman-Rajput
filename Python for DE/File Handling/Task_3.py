# Append Data to the File

text = '''
Emma, 20, B
Liam, 23, A'''

with open('students.txt','a') as f: 
    f.writelines(text)