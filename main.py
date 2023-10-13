from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from bson import ObjectId
from connection import collection

app = FastAPI()

class User(BaseModel):
    id: int
    name: str
    age: int
    description: str | None = None
    email: str | None = None

    class Config:
        arbitrary_types_allowed = True
        fields = {"id": "_id"}

def read_user(user : User):
    user_data = user.model_dump()
    try:
        user = collection.find_one({"_id" : user.id})
        if user:
            return user
        else:
            raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        #raise HTTPException(status_code=500, detail="An error occurred while processing the request")
        print (e)

def update_user(user: User, name: str, age: int):
    existing_user = read_user(user)
    if existing_user:
        update_data = {"$set": {"name": name, "age": age}}
        collection.update_one({"id": user.id}, update_data)  # Corrected query condition
    else:
        print ("no user found")
        new_user = User(id = user.id, name = name, age = age)
        collection.insert_one(new_user)

@app.get("/")
async def root():
    return {"message": "Hello world!"}

@app.get("/users/{user_id}")
async def get_user(user_id: int):
#   user_id_obj = ObjectId(user_id)  # Convert the user_id string to an ObjectId
    user_info = collection.find_one({"_id": user_id})

    return user_info
'''   
    if user_info:
        return User(**user_info)  # Create a User Pydantic model instance
    else:
        raise HTTPException(status_code=404, detail="User not found")
'''
        
@app.put("/users/{user_id}")
async def put_user(user_id: int, data: dict):
    name = data.get("name")
    age = data.get("age")
    update_user(User(id=user_id, name=name, age=age), name, age)  # Pass the ObjectId instance and the new 'name' and 'age'
    return {"message": "User information updated"}