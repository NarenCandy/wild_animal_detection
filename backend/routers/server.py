# backend/routers/server.py
import subprocess, os
from fastapi import APIRouter, Depends, Request
from backend.deps import get_current_user

router = APIRouter(prefix="/server", tags=["server"])

process = None  # track subprocess

@router.post("/start")
async def start_server(request: Request, current_user: dict = Depends(get_current_user)):
    global process
    if process and process.poll() is None:
        return {"status": "already running"}

    # extract raw JWT from request header
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return {"error": "Missing token"}
    token = auth_header.split(" ")[1]

    env = os.environ.copy()
    env["API_BASE_URL"] = "http://127.0.0.1:8000"
    env["API_TOKEN"] = token  # pass user’s token
    

    #process = subprocess.Popen(["python", "wild_animal_detection.py"], env=env)
    script_path = os.path.abspath("wild_animal_detection.py")
    python_path = os.path.abspath(os.path.join("venv", "Scripts", "python.exe"))

    process = subprocess.Popen([python_path, script_path], env=env)


    return {"status": "started"}

@router.post("/stop")
async def stop_server(current_user: dict = Depends(get_current_user)):
    global process
    if process and process.poll() is None:
        process.terminate()
        process = None
        return {"status": "stopped"}
    return {"status": "not running"}
