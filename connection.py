from pymongo import MongoClient

db_addr = "localhost"
db_ip = 27017


client = MongoClient(db_addr, db_ip)
db = client.users
collection = db.myusers