from fastapi import FastAPI

from connection import collection

app = FastAPI()

def read_user(user_id):
    user_data = collection.find_one({"_id": user_id})
    if user_data:
        # Convert ObjectId to string
        user_data["_id"] = str(user_data["_id"])
        return user_data
    return None

def update_user(user_id, name, age):
    user_data = read_user(user_id)
    if user_data:
        collection.update_one({"_id": user_id}, {"$set": {"name": name, "age": age}})
    else:
        new_user = {
            "_id": user_id,
            "name": name,
            "age": age
        }
        collection.insert_one(new_user)

@app.get("/")
async def root():
    return {"message": "Hello world!"}

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    user_info = read_user(user_id)
    if user_info:
        return user_info
    return {"message": "User not found"}

@app.put("/users/{user_id}")
async def put_user(user_id: int, data: dict):
    name = data.get("name")
    age = data.get("age")
    update_user(user_id, name, age)
    return {"message": "User information updated"}