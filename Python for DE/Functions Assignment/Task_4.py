products = [
{"name": "Laptop", "price": 1200},
{"name": "Phone", "price": 800},
{"name": "Tablet", "price": 600},
{"name": "Monitor", "price": 300}
]

discounted_prices = list(map(lambda x : {"name":x['name'],"price":x['price']*0.9},products))
print(discounted_prices)

expensive_products = list(filter(lambda p : p['price'] > 500, products))
print(expensive_products)