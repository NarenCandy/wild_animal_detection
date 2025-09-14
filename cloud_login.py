# test_full_flow.py
import os, requests
from dotenv import load_dotenv
import cloudinary.uploader

load_dotenv()
API_BASE = os.getenv("API_BASE_URL", "http://127.0.0.1:8000")
EMAIL = os.getenv("TEST_USER_EMAIL")
PASSWORD = os.getenv("TEST_USER_PASSWORD")

# Cloudinary config (cloudinary lib reads env vars)
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

# 1) Login (JSON login assumed)
login_resp = requests.post(f"{API_BASE}/auth/token", json={"email": EMAIL, "password": PASSWORD})
if login_resp.status_code != 200:
    print("Login failed:", login_resp.status_code, login_resp.text)
    raise SystemExit(1)

token = login_resp.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

# 2) Upload image to Cloudinary
local_image = "detected.jpg"
res = cloudinary.uploader.upload(local_image)
image_url = res.get("secure_url")
print("Uploaded image_url:", image_url)

# 3) Post alert to backend
payload = {"animal": "elephant", "image_url": image_url}
r = requests.post(f"{API_BASE}/alerts/", json=payload, headers=headers)
print("POST /alerts status:", r.status_code)
print("Response:", r.json())
