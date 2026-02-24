# Delete a File
import os 

path = r'C:\Users\aman.rajput\Downloads\Python for DE\students_backup.txt'
choice = input("Are you sure you want to delete ? (yes/no): ").strip().lower()
if choice == 'yes':
    os.remove(path)
    print("File deleted")
else:
    print("Deletion cancelled")