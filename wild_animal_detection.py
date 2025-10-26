import cv2
from ultralytics import YOLO
import cloudinary
import cloudinary.uploader
import requests
from datetime import datetime
import os, time
import numpy as np
from dotenv import load_dotenv

print("🐍 Detection script started")

# Load env vars
load_dotenv()
API_BASE = os.getenv("API_BASE_URL", "http://127.0.0.1:8000")
TOKEN = os.getenv("API_TOKEN")
CONF_THRESHOLD = 0.48

# Smart cooldown system
COOLDOWN_CONFIG = {
    "CRITICAL": 60,    # 1 min - immediate danger
    "HIGH": 30,       # 3 min - dangerous animals
    "MEDIUM": 30,     # 5 min - common animals
    "LOW": 600         # 10 min - monitoring only
}

# Alert level mapping
ALERT_LEVELS = {
    "tiger": "HIGH",
    "bear": "HIGH",
    "elephant": "MEDIUM",
    "boar": "MEDIUM",
    
}

if not TOKEN:
    print("❌ API_TOKEN not found in environment")

# Cloudinary config
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

# Load YOLO model
model = YOLO("C:\\Users\\naren\\wild_animal_detection\\best (4).pt")

# Webcam
cap = cv2.VideoCapture(0)

# Track last alert times and locations
last_alert_data = {}  # {class_name: {'time': timestamp, 'bbox': bbox}}

# Open log file
log_file = open("detections.log", "a", encoding="utf-8")


def log(message: str):
    """Write timestamped log message to file and console."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {message}"
    print(line)
    log_file.write(line + "\n")
    log_file.flush()


def calculate_bbox_similarity(bbox1, bbox2):
    """
    Calculate if two bounding boxes are similar (same animal in same position)
    Returns similarity score 0-1
    """
    if bbox1 is None or bbox2 is None:
        return 0
    
    # Calculate IoU (Intersection over Union)
    x1_inter = max(bbox1[0], bbox2[0])
    y1_inter = max(bbox1[1], bbox2[1])
    x2_inter = min(bbox1[2], bbox2[2])
    y2_inter = min(bbox1[3], bbox2[3])
    
    inter_area = max(0, x2_inter - x1_inter) * max(0, y2_inter - y1_inter)
    
    bbox1_area = (bbox1[2] - bbox1[0]) * (bbox1[3] - bbox1[1])
    bbox2_area = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
    
    union_area = bbox1_area + bbox2_area - inter_area
    
    if union_area == 0:
        return 0
    
    return inter_area / union_area


def check_proximity(animal_bbox, person_bbox, threshold=150):
    """
    Check if person is dangerously close to animal
    Returns distance in pixels
    """
    # Calculate center points
    animal_center = np.array([
        (animal_bbox[0] + animal_bbox[2]) / 2,
        (animal_bbox[1] + animal_bbox[3]) / 2
    ])
    person_center = np.array([
        (person_bbox[0] + person_bbox[2]) / 2,
        (person_bbox[1] + person_bbox[3]) / 2
    ])
    
    distance = np.linalg.norm(animal_center - person_center)
    return distance


def should_send_alert(class_name, bbox, alert_level, current_detections):
    """
    Smart decision: should we send alert or skip?
    Suppress alert if human is nearby.
    """
    now = time.time()
    cooldown = COOLDOWN_CONFIG.get(alert_level, 300)

    # Check for nearby humans
    for detection in current_detections:
        if detection['class'] == 'human':
            human_bbox = detection['bbox']
            proximity = check_proximity(bbox, human_bbox)
            if proximity < 150:  # You can tune this threshold
                log(f"🧍‍♂️ Human near {class_name} (distance={proximity:.1f}) – alert suppressed")
                return False

    # Check cooldown logic
    if class_name in last_alert_data:
        time_since_last = now - last_alert_data[class_name]['time']
        last_bbox = last_alert_data[class_name]['bbox']

        if time_since_last < cooldown:
            similarity = calculate_bbox_similarity(bbox, last_bbox)
            if similarity > 0.7:
                log(f"⏭️ Skipping duplicate {class_name} (same position, {time_since_last:.0f}s ago)")
                return False
            else:
                log(f"🆕 New {class_name} detected (different position)")
                return True
        else:
            return True
    else:
        return True



def get_alert_level(class_name, current_detections):
    
    base_level = ALERT_LEVELS.get(class_name, "MEDIUM")
    return base_level



# Main detection loop
frame_count = 0
PROCESS_EVERY_N_FRAMES = 5  # Process every 5th frame for efficiency

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    
    # Skip frames for efficiency
    if frame_count % PROCESS_EVERY_N_FRAMES != 0:
        cv2.imshow("YOLOv8 Live", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        continue
    
    results = model(frame)
    annotated_frame = results[0].plot()
    
    # Collect all current detections
    current_detections = []
    for box in results[0].boxes:
        cls_id = int(box.cls)
        class_name = results[0].names[cls_id]
        conf = float(box.conf)
        bbox = box.xyxyn[0].cpu().numpy()  # Normalized bbox
        
        if conf >= CONF_THRESHOLD:
            current_detections.append({
                'class': class_name,
                'conf': conf,
                'bbox': bbox
            })
    
    # Process each detection
    # Process each detection
    for detection in current_detections:
        class_name = detection['class']
        conf = detection['conf']
        bbox = detection['bbox']

        # Skip alert logic for humans
        if class_name == "human":
            log(f"👤 Human detected (conf={conf:.2f}) – no alert triggered")
            continue

        # Determine alert level
        alert_level = get_alert_level(class_name, current_detections)

        # Decide if we should alert
        if should_send_alert(class_name, bbox, alert_level, current_detections):
            log(f"✅ Detected {class_name} (conf={conf:.2f}, level={alert_level}) – sending alert")

            # Update tracking data
            last_alert_data[class_name] = {
                'time': time.time(),
                'bbox': bbox
            }

            # Save frame
            filename = f"detected_{class_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
            cv2.imwrite(filename, frame)

            # Upload to Cloudinary
            try:
                result = cloudinary.uploader.upload(filename)
                image_url = result.get("secure_url")
                log(f"☁️ Uploaded to Cloudinary: {image_url}")
                os.remove(filename)
            except Exception as e:
                log(f"❌ Cloudinary upload failed: {e}")
                image_url = None

            # Send to backend
            if image_url:
                headers = {"Authorization": f"Bearer {TOKEN}"}
                payload = {
                    "animal": class_name,
                    "image_url": image_url,
                    "alert_level": alert_level,
                    "confidence": conf,
                    "timestamp": datetime.now().isoformat()
                }
                try:
                    r = requests.post(f"{API_BASE}/alerts/", json=payload, headers=headers)
                    log(f"📡 Backend response: {r.json()}")
                except Exception as e:
                    log(f"❌ Backend error: {e}")

    
    cv2.imshow("YOLOv8 Live", annotated_frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
log_file.close()
