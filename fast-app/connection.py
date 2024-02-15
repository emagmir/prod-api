from pymongo import MongoClient
'''
Not required as we will connect with docudb conenction string
db_addr = "172.19.0.5"
db_ip = 27017
'''

client = MongoClient("here will be a conn string")
db = client.users
collection = db.myusers