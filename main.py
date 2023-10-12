from fastapi import FastAPI

app = FastAPI()

def read_user(user_id):
    with open("user_data.txt", "r") as file:
        for line in file:
            data = line.strip().split(",")
            if data[0] == str(user_id):
                return {
                    "user_id" : user_id,
                    "name" : data[1]
                    }
        return None
    
def update_user(user_id, name):
    user_data = read_user(user_id)
    if user_data is not None:
        user_data["name"] = name
    else:
        user_data = {
            "user_id" : user_id,
            "name" : name
            }
    with open("user_data.txt", "a") as file:
        file.write(f"{user_id},{name}\n")



@app.get("/")
async def root():
    return {"message" : "Hello world!"}


@app.get("/users/{user_id}")
async def get_user(user_id: int):
    user_info = read_user(user_id)
    if user_info:
        return user_info
    return {"message": "User not found"}

@app.put("/users/{user_id}")
async def put_user(user_id: int, name: str):
    update_user(user_id, name)
    return {"message": "User information updated"}