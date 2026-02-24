# Copy File Content
with open('students.txt','r') as f:
    with open('students_backup.txt','w') as w:
        for lines in f:
            w.writelines(lines)
            