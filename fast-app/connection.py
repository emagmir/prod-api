from pymongo import MongoClient

db_addr = "localhost"
db_ip = 27017


client = MongoClient(db_addr, db_ip)
db1 = client.users
db2 = client.items

userdb = db1.myusers

itemdb = db2.credentials