# schemas.py
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: str

class UserOut(BaseModel):
    id: Optional[str]
    name: str
    email: EmailStr
    phone: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    user_id: Optional[str]

    
class AlertIn(BaseModel):
    animal: str
    image_url: Optional[str] = None

class AlertOut(BaseModel):
    id: str
    user_id: str
    animal: str
    image_url: Optional[str] = None
    alert_level: str = "MEDIUM"
    timestamp: datetime

class AlertCreate(BaseModel):
    animal: str
    image_url: Optional[str] = None