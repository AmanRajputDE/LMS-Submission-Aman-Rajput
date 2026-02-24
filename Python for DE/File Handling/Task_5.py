# Update the File
with open('students.txt','r') as f:
    content = f.readlines()

result = []
for line in content:
    result.append(line.rstrip(' \n'))

final = [result[0]+"\n"]

for i in result[1:]:
    name,age,grade = i.split(", ")
    if name == "Sophie":
        age = '23'
    ls = [name,age,grade+"\n"]
    result = ", ".join(ls)
    final.append(result)

with open('students.txt','w') as f:
    f.writelines(final)

