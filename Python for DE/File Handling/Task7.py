# Error Handling

try:
    with open('non_existent_file.txt','r') as f:
        content = f.read()
except FileNotFoundError:
    print("The file you are trying to read does not exists")

except Exception as e:
    print(e)


