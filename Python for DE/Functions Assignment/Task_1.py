# Advanced Default and Keyword Arguments

def calculate_salary(base_salary,bonus_percent = 10,deductions = 5):
    return base_salary * (1 + float(bonus_percent)/100 - float(deductions)/100) 

print(calculate_salary(100))
print(calculate_salary(100,11,2))
print(calculate_salary(1000 , 10,deductions = 5))