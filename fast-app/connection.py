from pymongo import MongoClient
'''
Not required as we will connect with docudb conenction string
db_ip = 27017
'''
db_addr = "mongodb://pythonadmin:pythonadmin@db.fastmongo.com:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"


client = MongoClient(db_addr)
db = client.users
collection = db.myusers