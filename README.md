
# 🐾 Harmful Wildlife Detection for Farm Project

Welcome to the Harmful Wildlife Detection for Farm project! This repository contains the backend (FastAPI) and frontend (Flutter) components for real-time wildlife monitoring and alerts.

---

## ⚙️ Environment Setup

### 🐍 Python Backend
- **Python version:** 3.10.10  
- Create and activate a virtual environment:

```bash
python -m venv venv
```

**Activate on Linux/macOS:**
```bash
source venv/bin/activate
```

**Activate on Windows:**
```bash
venv\Scripts\activate
```

- Install backend dependencies:
```bash
pip install -r requirements.txt
```

---

### 💙 Flutter Frontend
- **Flutter version:** 3.24.5  
- **Dart version:** 3.5.4  
- **DevTools version:** 2.37.3  

Navigate to the frontend directory:
```bash
cd frontend
```

Install Flutter packages:
```bash
flutter pub get
```

---

## ▶️ Running the Project

### 🚀 Backend Server
Start the FastAPI backend server with hot reload:
```bash
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

### 📱 Frontend App
From the `frontend` folder, run:
```bash
flutter run
```

---

## 📱 Android Permissions

Ensure the following permission is added to:

`frontend/android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🌐 API Base URL

Configure the API base URL depending on your testing setup:

- **Android emulator:** `http://10.0.2.2:8000`


---

## 💡 Additional Notes

- Use virtual environments to avoid dependency conflicts.
- Always commit your `requirements.txt`, `pubspec.yaml`, and `pubspec.lock`.
- Frontend assets (e.g., custom MP3 files in `android/res/raw`) are included and versioned.
- Data folders like `combined_dataset` are ignored via `.gitignore` to avoid uploading large datasets.
- To download the dataset click this link 
- Just make sure that the camera feed url use different PORT, not the same as the API_BASE_URL

---

