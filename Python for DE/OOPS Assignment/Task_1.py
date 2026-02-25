# Create a Class

class Vehicle:
    def __init__(self,brand,model,year,price):
        self.brand = brand
        self.model = model
        self.year = year
        self.price = price
    
    def display_info(self):
        print(f"Brand :{self.brand}")
        print(f"Model :{self.model}")
        print(f"Year :{self.year}")
        print(f"Price :{self.price}")

v1 = Vehicle("Mercedes","S350d",2020,20000000)
v1.display_info()