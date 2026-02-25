# Encapsulation

class Vehicle:
    def __init__(self,brand,model,year,price):
        self.brand = brand
        self.model = model
        self.year = year
        self.__price = price # This is private variable 
    
    def get_price(self):
        return self.__price
    
    def set_price(self,new_price):
        self.__price = new_price
    
    def display_info(self):
        print(f"Brand :{self.brand}")
        print(f"Model :{self.model}")
        print(f"Year :{self.year}")
        print(f"Price :{self.__price}")

v1 = Vehicle("Mercedes","S350d",2020,20000000)
v1.display_info()

print(v1.get_price())
v1.set_price(2)
print(v1.get_price())

print(v1.__price) # This cannot be accessed 
print(v1._Vehicle__price) # This is the mangled name and can be accessed
