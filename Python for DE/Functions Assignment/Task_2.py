#  Higher-Order Function

def apply_discount(price,discount_function):

    return discount_function(price)

flat_discount = lambda price : price - 50
percet_discount = lambda price : price * 0.8

org_price = 100

print(apply_discount(org_price,flat_discount))
print(apply_discount(org_price,percet_discount)) 
