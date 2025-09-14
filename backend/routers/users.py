from fastapi import APIRouter, Depends, HTTPException
from backend.deps import get_current_user
from pydantic import BaseModel
from bson import ObjectId
from backend.database import users_collection

class PlayerIn(BaseModel):
    player_id: str

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/me")
async def get_me(current_user: dict = Depends(get_current_user)):
    return {
        "id": current_user["id"],
        "name": current_user["name"],
        "email": current_user["email"],
        "phone": current_user["phone"],
    }


@router.post("/player")
async def register_player(payload: PlayerIn, current_user: dict = Depends(get_current_user)):
    # current_user['id'] is string id (as we used earlier)
    user_obj_id = ObjectId(current_user["id"])
    # store many devices per user; addToSet prevents duplicates
    await users_collection.update_one(
        {"_id": user_obj_id},
        {"$addToSet": {"player_ids": payload.player_id}}
    )
    return {"ok": True}
