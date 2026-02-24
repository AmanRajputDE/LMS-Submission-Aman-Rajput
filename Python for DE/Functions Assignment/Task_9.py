# Data Transformation

data = [
{"name": "Alice", "age": 30, "score": 85},
{"name": "Bob", "age": 25, "score": 90},
{"name": "Charlie", "age": 35, "score": 95}
]
 
names = list(map(lambda x : x['name'] , data))
print(f"The names of all individuals are {names}")
score = list(map(lambda x : x['score'], data))
avg = sum(score)/len(score)
print(f"The average of all individual is {avg}")