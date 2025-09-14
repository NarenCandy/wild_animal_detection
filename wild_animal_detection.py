import cv2
from ultralytics import YOLO
import cloudinary
import cloudinary.uploader
import requests
from datetime import datetime
import os, time
from dotenv import load_dotenv
print("🐍 Detection script started")

# Load env vars
load_dotenv()
API_BASE = os.getenv("API_BASE_URL", "http://127.0.0.1:8000")
TOKEN = os.getenv("API_TOKEN")  # your JWT
CONF_THRESHOLD = 0.6
COOLDOWN = 10  # seconds
if not TOKEN:
    print("❌ API_TOKEN not found in environment")


# Cloudinary config
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

# Load YOLO model
model = YOLO("best.pt")

# Webcam
cap = cv2.VideoCapture(0)

# Track last alert times
last_alert_time = {}

# Open log file in append mode
log_file = open("detections.log", "a", encoding="utf-8")

def log(message: str):
    """Write timestamped log message to file and console."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {message}"
    print(line)
    log_file.write(line + "\n")
    log_file.flush()  # ensures it’s written immediately

while True:
    ret, frame = cap.read()
    if not ret:
        break

    results = model(frame)
    annotated_frame = results[0].plot()

    for box in results[0].boxes:
        cls_id = int(box.cls)
        class_name = results[0].names[cls_id]
        conf = float(box.conf)

        now = time.time()
        if conf >= CONF_THRESHOLD:
            if (class_name not in last_alert_time) or (now - last_alert_time[class_name] > COOLDOWN):
                last_alert_time[class_name] = now
                log(f"✅ Detected {class_name} (conf={conf:.2f}) – sending alert")

                # Save frame
                filename = f"detected_{class_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
                cv2.imwrite(filename, frame)

                # Upload to Cloudinary
                try:
                    result = cloudinary.uploader.upload(filename)
                    image_url = result.get("secure_url")
                    log(f"☁️ Uploaded to Cloudinary: {image_url}")
                except Exception as e:
                    log(f"❌ Cloudinary upload failed: {e}")
                    image_url = None

                # Send to backend
                if image_url:
                    headers = {"Authorization": f"Bearer {TOKEN}"}
                    payload = {"animal": class_name, "image_url": image_url}
                    try:
                        r = requests.post(f"{API_BASE}/alerts/", json=payload, headers=headers)
                        log(f"📡 Backend response: {r.json()}")
                    except Exception as e:
                        log(f"❌ Backend error: {e}")
        else:
            log(f"Skipped {class_name} (conf={conf:.2f} < {CONF_THRESHOLD})")

    cv2.imshow("YOLOv8 Live", annotated_frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
log_file.close()
