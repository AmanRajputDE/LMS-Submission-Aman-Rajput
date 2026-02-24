#  Functional Programming: Custom Aggregation

def custom_aggregate(arr,func):
    result = arr[0]
    for num in arr[1:]:
        result = func(result,num)
    return result

ls = [1,2,3,4,5]

sum_res = custom_aggregate(ls,lambda x,y : x+y)
print(f"The sum result is {sum_res}")
product_res = custom_aggregate(ls,lambda x,y : x*y)
print(f"The product result is {product_res}")