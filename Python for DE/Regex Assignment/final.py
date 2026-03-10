import re
from ipaddress import ip_address
from datetime import datetime
import json

content = ""
with open('data_log.txt','r') as r:
    content = r.read()

# 1. Extract All IP Addresses
all_ip = re.findall(r"(?<=IP )[0-9.]+",content)
sorted_ip = sorted(set(all_ip),key = ip_address)

print(sorted_ip)

# 2. Extract User Actions
lines = []
with open("data_log.txt","r") as f:
    lines = f.readlines()

user_actions = dict()

for line in lines:
    m = re.search(r".INFO: User (\w+) ([\w\s\D]+)\n",line)
    if m is None:
        continue
    else:
        if m.group(1) not in user_actions.keys():
            user_actions[m.group(1)] = {m.group(2)}
        else:
            user_actions[m.group(1)].add(m.group(2))

print(user_actions)

# 3. Validate and Extract Email Addresses
email_pattern = r"[\w]+@[\w]+\.[a-zA-Z]{2,}"
email_list = re.findall(email_pattern,content)
print("\nThe extracted emails:",email_list)

# 4. Extract Phone Numbers
number_pattern = r"(\d{3})-(\d{3})-(\d{4})"
number_list = re.findall(number_pattern,content)
number_set = set()
for number in number_list:
    full_number = number[0]+number[1]+number[2]
    number_set.add(full_number)
print("\nThe extracted numbers:",number_set)

# 5. Extract All URLs
url_pattern = r"^http://|https://\w+.\w+.\w+/*[^\s]*"
url_set = set(re.findall(url_pattern,content))
print("\nThe extracted urls:",url_set)

# 6. Classify Log Levels
log_level_pattern = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] (\w+):"
log_dict = dict()
for line in lines:
    m = re.search(log_level_pattern,line)
    if m is None:
        continue
    else:
        if m.group(1) not in log_dict.keys():
            log_dict[m.group(1)] = 1
        else:
            log_dict[m.group(1)] += 1

print("\nThe frequency of log levels are:",log_dict)

# 7. Extract Timestamps
timestamp_ls = []
timestamp_pattern = r"\[(?P<year>\d{4})-(?P<month>\d{2})-(?P<dom>\d{2}) (?P<hours>\d{2}):(?P<minutes>\d{2}):(?P<seconds>\d{2})\]"

for line in lines:
    m = re.search(timestamp_pattern,line)
    if m is None:
        continue
    else:
        dt = datetime(int(m.group("year")),int(m.group("month")),int(m.group("dom")),int(m.group("hours")),int(m.group("minutes")),int(m.group("seconds")))
        timestamp_ls.append(dt)

sorted_datetime_ls = sorted(timestamp_ls)
print("\nDisplaying the timestamps in ascending order:")
for item in sorted_datetime_ls:
    print(item)

# 8. Mask Sensitive Information
masked_ip = re.sub(r"(?<=IP )[0-9.]+","***.***.***.***",content)
masked_num = re.sub(r"(\d{3})-(\d{3})-(\d{4})","XXX-XXX-XXXX",masked_ip)
masked_email = re.sub(r"[\w]+@[\w]+\.[a-zA-Z]{2,}","hidden@example.com",masked_num)

with open("masked_data_log.txt","w") as f:
    f.write(masked_email)

# 9. Validate Error Codes
error_code_pattern = r"DB_ERR_\d+"
error_codes_set = set(re.findall(error_code_pattern,content))
print(error_codes_set)

# 10. Parse Log into Structured Format
message_pattern = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \w+: (.*)"

list_of_dict_records = []
for line in lines:
    dict_item = dict()
    ts = re.search(timestamp_pattern,line)
    ll = re.search(log_level_pattern,line)
    msg = re.search(message_pattern,line)

    if ts is None and ll is None and msg is None:
        continue
    else:
        dt = datetime(int(ts.group("year")),int(ts.group("month")),int(ts.group("dom")),int(ts.group("hours")),int(ts.group("minutes")),int(ts.group("seconds")))
        dict_item['timestamp'] = dt.strftime('%Y-%m-%d %H:%M:%S')
        dict_item['Log_level'] = ll.group(1) 
        dict_item['message'] = msg.group(1)

    list_of_dict_records.append(dict_item)

# json_string = json.dumps(list_of_dict_records,indent = 4)

with open('parsed_log.json','w') as f:
    json.dump(list_of_dict_records,f,indent = 4)
# print(json_string)    
    