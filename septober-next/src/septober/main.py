from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from pathlib import Path
from septober.config import get_settings
from septober.db import create_db_and_tables
from septober.api import todos, tags, ingest
from septober.broadcast import broadcaster

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

settings = get_settings()
app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    description="Septober Next — Procrastinators unite... with better technology! 🗓️",
    lifespan=lifespan,
)

# CORS for PWA frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(todos.router)
app.include_router(tags.router)
app.include_router(ingest.router)

# Health endpoints (Septober tradition!)
@app.get("/healthz")
def healthz():
    return {"status": "ok", "app": settings.app_name}

@app.get("/statusz")
def statusz():
    return {
        "app": settings.app_name,
        "version": settings.version,
        "env": settings.env,
        "ws_clients": broadcaster.client_count,
    }

# HTML Frontend with swipe gestures
@app.get("/")
def root():
    from fastapi.responses import HTMLResponse
    html_path = Path(__file__).parent / "static" / "index.html"
    return HTMLResponse(content=html_path.read_text(encoding="utf-8"))

# WebSocket for real-time updates
@app.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await broadcaster.connect(ws)
    try:
        while True:
            await ws.receive_text()  # Keep alive, ignore client messages
    except WebSocketDisconnect:
        broadcaster.disconnect(ws)

