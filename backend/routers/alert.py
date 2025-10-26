# backend/routers/alert.py

from fastapi import APIRouter, Depends
from datetime import datetime
from backend.schemas import AlertOut, AlertCreate
from backend.database import alerts_collection, users_collection
from backend.deps import get_current_user
from backend.notification import send_animal_alert  # ← Use new function
from bson import ObjectId

router = APIRouter(prefix="/alerts", tags=["alerts"])


def determine_alert_level(animal: str) -> str:
    """
    Determine alert severity based on animal type
    """
    alert_mapping = {
        "tiger": "HIGH",
        "bear": "HIGH",
        "elephant": "MEDIUM",
        "boar": "MEDIUM",
        "human": "LOW"
    }
    return alert_mapping.get(animal.lower(), "MEDIUM")


@router.post("/", response_model=AlertOut)
async def create_alert(
    alert: AlertCreate, 
    current_user: dict = Depends(get_current_user)
):
    """
    Create new wildlife alert and send OneSignal notification
    """
    # Determine alert level based on animal type
    alert_level = determine_alert_level(alert.animal)
    
    # Create alert document
    new_alert = {
        "user_id": current_user["id"],
        "animal": alert.animal,
        "image_url": alert.image_url,
        "alert_level": alert_level,  # ← Add alert level
        "timestamp": datetime.utcnow()
    }
    
    # Save to MongoDB
    result = await alerts_collection.insert_one(new_alert)
    alert_id = str(result.inserted_id)
    
    print(f"📥 Alert created: {alert.animal} ({alert_level}) - ID: {alert_id}")
    
    # Get user's player IDs for targeted notification
    try:
        user_doc = await users_collection.find_one({"_id": ObjectId(current_user["id"])})
        player_ids = user_doc.get("player_ids", []) if user_doc else []
    except Exception as e:
        print(f"⚠️ Failed to get player_ids: {e}")
        player_ids = []
    
    # Send OneSignal notification with custom sound
    try:
        if player_ids:
            # Send to specific user
            print(f"📤 Sending notification to {len(player_ids)} device(s)")
            notification_result = await send_animal_alert(
                animal_type=alert.animal,
                image_url=alert.image_url,
                alert_level=alert_level,
                location="Your Farm",
                player_ids=player_ids  # ← Specific users
            )
        else:
            # Fallback: send to all users (if no player_ids registered)
            print(f"📤 No player_ids found, sending to all users")
            notification_result = await send_animal_alert(
                animal_type=alert.animal,
                image_url=alert.image_url,
                alert_level=alert_level,
                location="Farm Camera",
                player_ids=None  # ← None = all users
            )
        
        if notification_result:
            print(f"✅ OneSignal notification sent successfully")
        else:
            print(f"⚠️ OneSignal notification returned no result")
            
    except Exception as e:
        print(f"❌ OneSignal notification failed: {e}")
        # Don't fail the request if notification fails
    
    return {**new_alert, "id": alert_id}


@router.get("/me")
async def get_my_alerts(current_user: dict = Depends(get_current_user)):
    """
    Get all alerts for the current user
    """
    cursor = alerts_collection.find({"user_id": str(current_user["id"])})
    alerts = []
    
    async for alert in cursor:
        alerts.append({
            "id": str(alert["_id"]),
            "user_id": alert["user_id"],
            "animal": alert["animal"],
            "image_url": alert.get("image_url"),
            "alert_level": alert.get("alert_level", "MEDIUM"),  # ← Include alert level
            "timestamp": alert["timestamp"]
        })
    
    # Sort by timestamp, newest first
    alerts.sort(key=lambda x: x["timestamp"], reverse=True)
    
    return {"alerts": alerts}


@router.delete("/{alert_id}")
async def delete_alert(
    alert_id: str, 
    current_user: dict = Depends(get_current_user)
):
    """
    Delete a specific alert (optional endpoint)
    """
    try:
        result = await alerts_collection.delete_one({
            "_id": ObjectId(alert_id),
            "user_id": current_user["id"]  # Ensure user owns the alert
        })
        
        if result.deleted_count == 0:
            return {"success": False, "message": "Alert not found or unauthorized"}
        
        return {"success": True, "message": "Alert deleted"}
        
    except Exception as e:
        return {"success": False, "message": str(e)}
