from pymongo import MongoClient

db_addr = "mongodb://pythonadmin:pythonadmin@db.fastmongo.com:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
db_ip = 27017


client = MongoClient(db_addr)
db = client.users
collection = db.myusers
#