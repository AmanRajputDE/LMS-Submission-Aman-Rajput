from abc import ABC, abstractmethod
import math 

class Shape(ABC):
    @abstractmethod
    def calculate_area(self):
        pass

class Rectangle(Shape):
    
    def __init__(self,length,breadth):
        self.length = length
        self.breadth = breadth
    
    def calculate_area(self):
        self.area = self.length * self.breadth
        return self.area

class Circle(Shape):

    def __init__(self,radius):
        self.radius = radius
    
    def calculate_area(self):
        self.area = math.pi * (self.radius ** 2)
        return self.area


r1 = Rectangle(2,3)
print(r1.calculate_area())

c1 =  Circle(4)
print(c1.calculate_area())