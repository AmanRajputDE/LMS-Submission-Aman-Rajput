# Word Count
word_entered = "in"
with open(r'C:\Users\aman.rajput\Downloads\Python for DE\paragraph.txt','r') as f:
    count_total = len(f.read().split())
    user_count = 0
    f.seek(0)
    for word in f.read().split():
        if word == word_entered:
            user_count += 1
    print(count_total)
    print(user_count)
