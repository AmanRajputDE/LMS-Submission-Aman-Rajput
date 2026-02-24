def operation(arr,func):
    result = arr[0]
    for num in arr[1:]:
        result = func(result,num)
    return result


def dynamic_function(arr,ops):
    if ops == 'add':
        print(operation(arr,lambda x,y : x+y))
    elif ops == 'subtract':
        print(operation(arr,lambda x,y : x-y))
    elif ops == 'multiply':
        print(operation(arr,lambda x,y : x*y))
    elif ops == 'divide':
        print(operation(arr,lambda x,y : x/y))




ls = [1,2,3,4,5]
dynamic_function(ls,"add")
dynamic_function(ls,"subtract")
dynamic_function(ls,"multiply")

ls = [4,2]
dynamic_function(ls,"divide")