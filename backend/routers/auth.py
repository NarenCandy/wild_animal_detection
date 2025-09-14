# auth.py
from fastapi import APIRouter, HTTPException, status, Depends
from backend.schemas import UserCreate, Token
from backend.database import users_collection
from backend.models import hash_password, verify_password, create_access_token
from bson import ObjectId
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=dict)
async def register(user: UserCreate):
    # check existing email
    existing = await users_collection.find_one({"email": user.email})
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    user_dict = user.dict()
    hashed = hash_password(user_dict.pop("password"))
    new_user= {
        "name": user.name,
        "email": user.email,
        "password": hashed,
        "phone": user.phone 
    }
    
    res = await users_collection.insert_one(new_user)
    return {"message":"user_created", "user_id": str(res.inserted_id)}

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/token", response_model=Token)
async def login_for_access_token(data: LoginRequest):
    user = await users_collection.find_one({"email": data.email})
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect credentials")
    if not verify_password(data.password, user["password"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect credentials")
    access_token = create_access_token({"user_id": str(user["_id"]), "email": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}