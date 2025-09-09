
import cv2
from ultralytics import YOLO

# Load your trained model
model = YOLO("best.pt")  # path to your trained weights

# Open webcam (0 = default camera)
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Run YOLO on the frame
    results = model(frame)

    # Draw results on the frame
    annotated_frame = results[0].plot()

    # Print detected classes in console
    for box in results[0].boxes:
        cls_id = int(box.cls)
        class_name = results[0].names[cls_id]
        print("Detected:", class_name)

    # Show the live annotated frame
    cv2.imshow("YOLOv8 Live", annotated_frame)

    # Press 'q' to quit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
