# cloud_test.py
import os
from dotenv import load_dotenv
import cloudinary.uploader

load_dotenv()

cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
api_key = os.getenv("CLOUDINARY_API_KEY")
api_secret = os.getenv("CLOUDINARY_API_SECRET")

cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret
)

local_path = "detected.jpg"   # change if your file is elsewhere

if not os.path.exists(local_path):
    raise SystemExit(f"{local_path} not found")

res = cloudinary.uploader.upload(local_path)
print("Upload result keys:", list(res.keys()))
print("secure_url:", res.get("secure_url"))
