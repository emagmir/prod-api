from fastapi import FastAPI, HTTPException, Body, status
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from bson import ObjectId
from connection import collection

app = FastAPI()

class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v, context=None):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __get_pydantic_json_schema__(cls, field_schema):
        field_schema.update(type="string")

class UserModel(BaseModel):
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    name: str = Field(...)
    email: EmailStr = Field(...)
    address : str = Field(...)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "name": "Jane Doe",
                "email": "jdoe@example.com",
                "address" : "Str. Long nr. 25"
            }
        }

class UpdateUserModel(BaseModel):
    name: Optional[str]
    email: Optional[EmailStr]
    address: Optional[str]

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "name": "Jane Doe",
                "email": "jdoe@example.com",
                "address" : "Str. Long nr. 25"
            }
        }

@app.post("/users/", response_description="Add new student", response_model=UserModel)
async def create_user(user: UserModel = Body(...)):
    user = jsonable_encoder(user)
    new_user = collection.insert_one(user)
    created_user = collection.find_one({"_id": new_user.inserted_id})
    return created_user

@app.get(
    "/users/", response_description="List all students", response_model=List[UserModel]
)
async def list_users():
    students = collection.find()
    return students

@app.get(
    "/health", response_description="List all students"
)
async def list_users():
    return "i swear it worked on my pc / asta e pt tudor"

@app.get(
    "/users/{id}", response_description="Get a single user", response_model=UserModel
)
async def show_user(id: str):
    if (user := collection.find_one({"_id": id})) is not None:
        return user

    raise HTTPException(status_code=404, detail=f"User {id} not found")

@app.put("/users/{id}", response_description="Update a user", response_model=UserModel)
async def update_user(id: str, user: UpdateUserModel = Body(...)):
    user = {k: v for k, v in user.model_dump().items() if v is not None}

    if len(user) >= 1:
        update_result = collection.update_one({"_id": id}, {"$set": user})

        if update_result.modified_count == 1:
            if (
                updated_user := collection.find_one({"_id": id})
            ) is not None:
                return updated_user

    if (existing_user := collection.find_one({"_id": id})) is not None:
        return existing_user

    raise HTTPException(status_code=404, detail=f"User {id} not found")

@app.delete("/users/{id}", response_description="Delete a user")
async def delete_user(id: str):
    delete_result = collection.delete_one({"_id": id})

    if delete_result.deleted_count == 1:
        return "already deleted"

    raise HTTPException(status_code=404, detail=f"User {id} not found")