from pymongo import MongoClient

db_addr = "mongodb-service"
db_ip = 27017


client = MongoClient(db_addr, db_ip)
db = client.users
collection = db.myusers