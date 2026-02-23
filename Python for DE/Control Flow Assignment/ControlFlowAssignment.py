# Login Validation
users = {
    'trainer1' : 'Train@123',
    'trainer2' : 'Learn@123'
}
is_login = False

print()
print("#######################")
print("######## LOGIN ########")
print("#######################")
print()

for i in range(0,3):
    user_id = input('Enter the username :')
    password = input('Enter the password :')

    if user_id not in users.keys() or password != users[user_id]:
        print("Incorrect Details")
    else: 
        is_login = True
        print(f"Welcome back {user_id} !")
        break



if is_login:

    print()
    print("#######################")
    print("##### DATA ENTRY #####")
    print("#######################")
    print()

    data_entry = list()
    data_entry_count = 0 
    while data_entry_count != 3:
        print(f"Record {data_entry_count +1 }")
        trainee_name = str(input("Enter the Trainee name :"))
        python_marks = float(input("Enter the Python Basics marks :"))
        ds_marks = float(input("Enter the Data Structures marks :"))
        cf_marks = float(input("Enter the Control Flow marks :"))
        
        marks_list = [python_marks,ds_marks,cf_marks]
        
        if all(num <= 100 for num in marks_list) and all(num >= 0 for num in marks_list):
            data_entry.append({
                'name':trainee_name,
                'python_marks':python_marks,
                'data_structure_marks': ds_marks,
                'control_flow_marks': cf_marks
            })
            data_entry_count += 1
        else:
            print("!!!!!!!! The marks should be between 0 and 100 !!!!!!!!")
        
    choice = input("Do you wish to continue(yes/no): ")   
    while choice.lower() != "no":
        trainee_name = str(input("Enter the Trainee name :"))
        python_marks = float(input("Enter the Python Basics marks :"))
        ds_marks = float(input("Enter the Data Structures marks :"))
        cf_marks = float(input("Enter the Control Flow marks :"))

        marks_list = [python_marks,ds_marks,cf_marks]
        
        if all(num <= 100 for num in marks_list) and all(num >= 0 for num in marks_list):
            print("Everything all right")
            data_entry.append({
                'name':trainee_name,
                'python_marks':python_marks,
                'data_structure_marks': ds_marks,
                'control_flow_marks': cf_marks
            })
            data_entry_count += 1
        else:
            print("The marks should be between 0 and 100")
        
        choice = input("Do you wish to continue(yes/no): ")  
    
    print(f"Total number of records entered : {data_entry_count}")
    
    print()    
    print("#######################")
    print("##### EVALUATION #####")
    print("#######################")
    print()

    for i in data_entry:
        i['total'] = i['python_marks'] + i['data_structure_marks'] + i['control_flow_marks']
        i['average'] = i['total']/3
        if i['average'] >= 85:
            i['grade'] = 'Excellent'
        elif i['average'] >= 70 and i['average'] <= 84:
            i['grade'] = 'Good'
        elif i['average'] >= 50 and i['average'] <= 69:
            i['grade'] = 'Average'
        else:
            i['grade'] = 'Needs Improvement'
        
        marks_list = [i['python_marks'] , i['data_structure_marks'] , i['control_flow_marks']]
        if any(num < 40 for num in marks_list):
            i['isFail'] = True
        else:
            i['isFail'] = False
        
    print()
    print("#######################")
    print("###### ANALYTICS ######")
    print("#######################")    
    print()

    highest_name = ''
    highest_avg = 0

    lowest_name = ''
    lowest_avg = 999

    cnt_of_trainee_grd = dict()
    failed_trainee = []

    for i in data_entry:

        if i['grade'] not in cnt_of_trainee_grd.keys():
            cnt_of_trainee_grd[i['grade']] = 1
        else:
            cnt_of_trainee_grd[i['grade']] += 1

        if i['average'] > highest_avg:
            highest_avg = i['average']
            highest_name = i['name']
        if i['average'] < lowest_avg:
            lowest_avg = i['average']
            lowest_name = i['name']
        if i['isFail']:
            failed_trainee.append(i['name'])


    print(f"Highest average scorer name : {highest_name} with marks : {highest_avg}")
    print(f"Highest average scorer name : {lowest_name} with marks : {lowest_avg}")
    print(cnt_of_trainee_grd)
    print(f"Trainees who failed are: {failed_trainee}")

    remedial_choice = input("Do you want to schedule remedial training? (yes/no) :")
    if remedial_choice.lower() == 'yes':
        print(failed_trainee)
    else:
        print("Report finalized successfully")

else:
    print("Access Denied. Please contact admin.")