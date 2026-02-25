# Method Overloading

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
    
    def calculate_discount(self,percentage,add_discount = 0): #This is the only way to implement method overloading
        self.discounted_price = self.__price - (self.__price * percentage)/100 - add_discount
        return self.discounted_price
    
v1 = Vehicle("Mercedes","S350d",2020,20000000)
print(v1.calculate_discount(10))
print(v1.calculate_discount(10,1))
        
