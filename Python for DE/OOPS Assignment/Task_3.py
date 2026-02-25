# Inheritance

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

class Car(Vehicle):
    def __init__(self,brand,model,year,price,number_of_doors):
        super().__init__(brand,model,year,price)
        self.number_of_doors = number_of_doors
    
    def display_info(self):
        print(f"Brand :{self.brand}")
        print(f"Model :{self.model}")
        print(f"Year :{self.year}")
        print(f"Price :{self.get_price()}")
        print(f"Number of Doors :{self.number_of_doors}")

c1 = Car("Mercedes","S350d",2020,20000000,4)
c1.display_info()