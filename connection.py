from pymongo import MongoClient
'''
Not required as we will connect with docudb conenction string
db_addr = "172.19.0.5"
db_ip = 27017
'''

client = MongoClient("connection string")
db = client.users
collection = db.myusers