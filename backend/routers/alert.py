# backend/routers/alert.py
from fastapi import APIRouter, Depends
from datetime import datetime
from backend.schemas import AlertOut, AlertCreate
from backend.database import alerts_collection
from backend.deps import get_current_user
import cloudinary.uploader
from backend.database import alerts_collection, users_collection
from backend.notification import send_onesignal_notification
from bson import ObjectId

router = APIRouter(prefix="/alerts", tags=["alerts"])

@router.post("/", response_model=AlertOut)
async def create_alert(alert: AlertCreate, current_user: dict = Depends(get_current_user)):
    new_alert = {
        "user_id": current_user["id"],  # user id comes from token
        "animal": alert.animal,
        "image_url": alert.image_url,
        "timestamp": datetime.utcnow()
    }
    result = await alerts_collection.insert_one(new_alert)
    alert_id = str(result.inserted_id)

    try:
        user_doc = await users_collection.find_one({"_id": ObjectId(current_user["id"])})
        player_ids = user_doc.get("player_ids", []) if user_doc else []
    except Exception:
        player_ids = []
    if player_ids:
        heading = "Wild Animal Detected"
        message = f"{new_alert['animal'].capitalize()} detected near your farm"
        data = {"alert_id": alert_id, "image_url": new_alert["image_url"]}  
        try:
            await send_onesignal_notification(player_ids, heading, message, data, url=new_alert["image_url"])  
        except Exception as e:
            print(f"❌ OneSignal notification failed: {e}")
    return {**new_alert, "id": alert_id}

@router.get("/me")
async def get_my_alerts(current_user: dict = Depends(get_current_user)):
    cursor = alerts_collection.find({"user_id": str(current_user["id"])})
    alerts = []
    async for alert in cursor:
        alerts.append({
            "id": str(alert["_id"]),   # ✅ fixed here
            "user_id": alert["user_id"],
            "animal": alert["animal"],
            "image_url": alert.get("image_url"),
            "timestamp": alert["timestamp"]
        })
    return {"alerts": alerts}
