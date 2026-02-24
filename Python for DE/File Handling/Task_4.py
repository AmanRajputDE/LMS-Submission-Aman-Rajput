# Analyze the File

with open('students.txt','r') as f:
    content = f.readlines()
    print(f"The total number of students in the file :{len(content) - 1}")
    count_of_grade_A_students = 0
    for i in content[1:]:
        rcd_ls = i.split(",")
        if 'A' in rcd_ls[2]:
            count_of_grade_A_students += 1
    
    print(f"The number of students who received a grade 'A' :{count_of_grade_A_students}")