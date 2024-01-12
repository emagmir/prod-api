from pymongo import MongoClient
'''
Not required as we will connect with docudb conenction string
db_addr = "172.19.0.5"
db_ip = 27017
'''

client = MongoClient("mongodb://pythonadmin:pythonadmin@docudb-fast-api.cluster-ckrpn1rvr9wq.us-east-1.docdb.amazonaws.com:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false")
db = client.users
collection = db.myusers