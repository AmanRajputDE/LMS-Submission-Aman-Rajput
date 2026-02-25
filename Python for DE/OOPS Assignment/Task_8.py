# Real-World Application
class Library:
    def __init__(self,books):
        self.books = books
    
    def display(self):
        print(self.books)

    def borrow(self,book):
        self.books.pop(self.books.index(book))
    
    def returnbook(self,book):
        self.books.append(book)

books_list = ['A','B','C']
l1 = Library(books_list)

l1.display()

l1.borrow('A')
l1.display()

l1.returnbook('A')
l1.display()