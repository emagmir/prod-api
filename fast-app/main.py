from fastapi import FastAPI, HTTPException, Body, status, Depends
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel, EmailStr, Field, PositiveInt
from typing import Optional, List, Annotated
from bson import ObjectId
from connection import userdb, itemdb
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordBearer, OAuth2PasswordRequestForm
from datetime import datetime, timedelta, timezone
from typing import Annotated
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic.functional_validators import BeforeValidator
from pymongo import ReturnDocument

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

origins = [
    'https://localhost:3000'
]

app.add_middleware(
    CORSMiddleware, 
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*']
)

SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: str | None = None

PyObjectId = Annotated[str, BeforeValidator(str)]

'''class PyObjectId(ObjectId):
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
        field_schema.update(type="string")'''

'''
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
'''
        
class User(BaseModel):
    _id: ObjectId
    username: str
    email: str | None = None
    full_name: str | None = None
    disabled: bool | None = None

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "username" : "johndoe12",
                "email": "jdoe@example.com",
                "full_name" : "John Doe",
                "disabled" : False
            }
        }

class UserInDB(User):
    hashed_password: str


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(collection, username: str):
    user_document = collection.find_one({"username": username})
    if user_document:
        return UserInDB(**user_document)

def authenticate_user(collection, username: str, password: str):
    user = get_user(collection, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
        print(token_data)
    except JWTError:
        raise credentials_exception
    user = get_user(userdb, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user


async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)]
):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user


@app.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
) -> Token:
    user = authenticate_user(userdb, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return Token(access_token=access_token, token_type="bearer")


@app.get("/users/me/", response_model=User)
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)]
):
    return current_user


@app.get("/users/me/items/")
async def read_own_items(
    current_user: Annotated[User, Depends(get_current_active_user)]
):
    return [{"item_id": "Foo", "owner": current_user.username}]

#login and signup





class InventoryItem(BaseModel):
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    sku: str  # Stock Keeping Unit
    name: str
    description: str
    quantity_in_stock: int
    location: str  # Location in the warehouse/store
    # Add more attributes as needed, such as price, supplier information, etc.

    class Config:
        allow_population_by_field_name = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "sku": "ABC123",
                "name": "Widget",
                "description": "A versatile widget for various purposes",
                "quantity_in_stock": 100,
                "location": "Aisle 1, Shelf 3"
            }
        }


class UpdateInventoryItemModel(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    quantity_in_stock: Optional[int] =None # Ensure positive integer values
    location: Optional[str] = None

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        schema_extra = {
            "example": {
                "name": "Updated Widget",
                "description": "A more detailed description of the widget",
                "quantity_in_stock": 150,
                "location": "Aisle 2, Shelf 1"
            }
        }

'''
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
'''
        
@app.post("/items/", response_description="Add new item", response_model=InventoryItem)
async def create_item(item: InventoryItem = Body(...)):
    '''item = jsonable_encoder(item)
    new_item = itemdb.insert_one(item)
    created_item = itemdb.find_one({"_id": new_item.inserted_id})
    return created_item'''

    new_item = itemdb.insert_one(
        item.model_dump(by_alias=True, exclude=["id"])
    )
    created_item = itemdb.find_one(
        {"_id": new_item.inserted_id}
    )
    return created_item

@app.get(
    "/items/", response_description="List all items", response_model=List[InventoryItem]
)
async def list_items():
    all_items = itemdb.find()
    return all_items

@app.get(
    "/health", response_description="Check if app is running"
)
async def check_health():
    return "i swear it worked locally"

@app.get(
    "/items/{id}", response_description="Get a single item", response_model=InventoryItem
)
async def show_item(id: str):
    if (item := itemdb.find_one({"_id": ObjectId(id)})) is not None:
        return item

    raise HTTPException(status_code=404, detail=f"Item {id} not found")

@app.put("/items/{id}", response_description="Update an item", response_model=InventoryItem, response_model_by_alias=False)
async def update_item(id: str, item: UpdateInventoryItemModel = Body(...)):
    item = {k: v for k, v in item.model_dump(by_alias=True).items() if v is not None}

    if len(item) >= 1:
        update_result = itemdb.find_one_and_update({"_id": ObjectId(id)}, {"$set": item}, return_document=ReturnDocument.AFTER)

        if update_result is not None:
            return update_result
        else:
            raise HTTPException(status_code=404, detail=f"Item {id} not found")

    if (existing_item := itemdb.find_one({"_id": id})) is not None:
        return existing_item

    raise HTTPException(status_code=404, detail=f"Item {id} not found")

@app.delete("/items/{id}", response_description="Delete an item")
async def delete_item(id: str):
    delete_result = itemdb.delete_one({"_id": ObjectId(id)})

    if delete_result.deleted_count == 1:
        return "already deleted"

    raise HTTPException(status_code=404, detail=f"Item {id} not found")