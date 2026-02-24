# Combining Lambda and Functions

def analyze_numbers(arr):
    sq_num = list(map(lambda x : x**2 , arr))
    filtered_num = list(filter(lambda x : x > 50,sq_num))
    return filtered_num


ls = [1,2,3,4,5,6,7,8,9,10]
print(analyze_numbers(ls))