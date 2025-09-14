import os
import httpx
from dotenv import load_dotenv

load_dotenv()

ONESIGNAL_APP_ID = os.getenv("ONESIGNAL_APP_ID")
ONESIGNAL_REST_KEY = os.getenv("ONESIGNAL_REST_API_KEY")
ONESIGNAL_URL = "https://onesignal.com/api/v1/notifications"

async def send_onesignal_notification(player_ids, heading, message, data=None, url=None):
    """Send push notification via OneSignal to specified player_ids."""
    if not player_ids:
        return None

    headers = {
        "Authorization": f"Basic {ONESIGNAL_REST_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "app_id": ONESIGNAL_APP_ID,
        "include_player_ids": player_ids,
        "headings": {"en": heading},
        "contents": {"en": message},
        "priority": 10,
        "android_sound": "alert_sound.wav"
    }

    if data:
        payload["data"] = data

    if url:
        payload["url"] = url

    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.post(ONESIGNAL_URL, json=payload, headers=headers)
        response.raise_for_status()
        return response.json()
