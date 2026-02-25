# File Handling with OOP
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
    
    def save_to_file(self):
        with open(f'{self.brand}_{self.model}.txt','w') as f:
            f.write(f"Brand :{self.brand}\n")
            f.write(f"Model :{self.model}\n")
            f.write(f"Year :{self.year}\n")
            f.write(f"Price :{self.__price}\n")

v1 = Vehicle("Mercedes","S350d",2020,20000000)
v1.save_to_file()
