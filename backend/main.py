from fastapi import FastAPI
from backend.routers.auth import router as auth_router
from backend.routers.alert import router as alerts_router

from backend.routers import server, users

app = FastAPI(title="Animal Alert Backend")

app.include_router(auth_router)
app.include_router(alerts_router)
app.include_router(users.router) 
app.include_router(server.router)


@app.get("/")
def root():
    return {"message": "Animal Alert Backend running"}
