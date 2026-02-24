# Sorting with Lambda
products = [
{"name": "Laptop", "price": 1200},
{"name": "Phone", "price": 800},
{"name": "Tablet", "price": 600},
{"name": "Monitor", "price": 300}
]

sorted_by_price  = sorted(products,key = lambda p : p['price'])
sorted_by_price_desc  = sorted(products,key = lambda p : p['price'],reverse = True)
print(sorted_by_price)
print(sorted_by_price_desc)