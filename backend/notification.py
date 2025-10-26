# backend/notification.py

import os
import httpx
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

ONESIGNAL_APP_ID = os.getenv("ONESIGNAL_APP_ID")
ONESIGNAL_REST_KEY = os.getenv("ONESIGNAL_REST_API_KEY")
ONESIGNAL_URL = "https://onesignal.com/api/v1/notifications"

print(f"✅ OneSignal configured: {ONESIGNAL_APP_ID[:8] if ONESIGNAL_APP_ID else '❌ Missing'}...")


async def send_animal_alert(
    animal_type: str,
    image_url: str,
    alert_level: str = "MEDIUM",
    location: str = "Unknown",
    player_ids: list = None
):
    """
    Send wildlife detection alert via OneSignal
    """
    animal_emoji = {
        "tiger": "🐅",
        "bear": "🐻",
        "elephant": "🐘",
        "boar": "🐗",
        "human": "👤"
    }
    
    # ALL levels need channel_id
    alert_config = {
        "CRITICAL": {
            "emoji": "🚨",
            "channel_id": "2fe37f53-0fc7-4e4f-94c0-8dac5edd28de"
        },
        "HIGH": {
            "emoji": "🔴",
            "channel_id": "2fe37f53-0fc7-4e4f-94c0-8dac5edd28de"
        },
        "MEDIUM": {
            "emoji": "🟡",
            "channel_id": "2fe37f53-0fc7-4e4f-94c0-8dac5edd28de"
        },
        "LOW": {
            "emoji": "🟢",
            "channel_id": "2fe37f53-0fc7-4e4f-94c0-8dac5edd28de"  # ← FIXED: Added channel_id
        }
    }
    
    config = alert_config.get(alert_level, alert_config["MEDIUM"])
    emoji = animal_emoji.get(animal_type.lower(), "🦁")
    
    headers = {
        "Authorization": f"Basic {ONESIGNAL_REST_KEY}",
        "Content-Type": "application/json",
    }
    
    payload = {
        "app_id": ONESIGNAL_APP_ID,
        "headings": {"en": f"{config['emoji']} Wildlife Alert"},
        "contents": {"en": f"{emoji} {animal_type.upper()} detected at {location}"},
        "data": {
            "animal_type": animal_type,
            "image_url": image_url,
            "alert_level": alert_level,
            "location": location,
            "timestamp": datetime.now().isoformat()
        },
        "big_picture": image_url,
        "large_icon": image_url,
        "priority": 10,
        "android_channel_id": config["channel_id"],
    }
    
    if player_ids and len(player_ids) > 0:
        payload["include_player_ids"] = player_ids
        print(f"📤 Sending to {len(player_ids)} device(s)")
    else:
        payload["included_segments"] = ["All"]
        print(f"📤 Sending to all users")
    
    print(f"   {animal_type} | {alert_level} | Channel: {config['channel_id'][:8]}...")
    
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.post(ONESIGNAL_URL, json=payload, headers=headers)
            response.raise_for_status()
            result = response.json()
            
            recipients = result.get("recipients", 0)
            print(f"✅ Sent! Recipients: {recipients}")
            
            if recipients == 0:
                print("⚠️ No recipients - check if app is subscribed")
            
            return result
            
    except httpx.HTTPStatusError as e:
        print(f"❌ HTTP Error {e.response.status_code}: {e.response.text}")
        return None
    except Exception as e:
        print(f"❌ Error: {type(e).__name__}: {e}")
        return None


# Legacy function
async def send_onesignal_notification(player_ids, heading, message, data=None, url=None):
    """Old function - still works"""
    if not player_ids:
        player_ids = None
    
    headers = {
        "Authorization": f"Basic {ONESIGNAL_REST_KEY}",
        "Content-Type": "application/json",
    }
    
    payload = {
        "app_id": ONESIGNAL_APP_ID,
        "headings": {"en": heading},
        "contents": {"en": message},
        "priority": 10,
        "android_channel_id": "2fe37f53-0fc7-4e4f-94c0-8dac5edd28de",
    }
    
    if player_ids:
        payload["include_player_ids"] = player_ids
    else:
        payload["included_segments"] = ["All"]
    
    if data:
        payload["data"] = data
    
    if url:
        payload["url"] = url
    
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(ONESIGNAL_URL, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
