from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from septober.config import get_settings
from septober.db import create_db_and_tables
from septober.api import todos, tags, ingest

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
    }

@app.get("/")
def root():
    from fastapi.responses import HTMLResponse
    html = """<!DOCTYPE html>
<html lang="it">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Septober Next 🗓️</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
         background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); color: #e0e0e0;
         min-height: 100vh; }
  .container { max-width: 600px; margin: 0 auto; padding: 20px; }
  header { text-align: center; padding: 40px 0 20px; }
  header h1 { font-size: 2.5em; background: linear-gradient(90deg, #f7971e, #ffd200);
              -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
  header p { color: #aaa; margin-top: 8px; font-style: italic; }
  .stats { display: flex; gap: 12px; justify-content: center; margin: 20px 0; }
  .stat { background: rgba(255,255,255,0.08); border-radius: 12px; padding: 12px 20px;
          text-align: center; min-width: 80px; }
  .stat-num { font-size: 1.8em; font-weight: 700; color: #ffd200; }
  .stat-label { font-size: 0.75em; color: #888; text-transform: uppercase; }
  .add-form { display: flex; gap: 8px; margin: 20px 0; }
  .add-form input { flex: 1; padding: 12px 16px; border-radius: 12px; border: 1px solid #444;
                     background: rgba(255,255,255,0.06); color: #fff; font-size: 16px; outline: none; }
  .add-form input:focus { border-color: #ffd200; }
  .add-form button { padding: 12px 20px; border-radius: 12px; border: none;
                      background: linear-gradient(135deg, #f7971e, #ffd200); color: #1a1a2e;
                      font-weight: 700; cursor: pointer; font-size: 16px; }
  .add-form button:hover { transform: scale(1.05); }
  .todo-list { list-style: none; }
  .todo-item { display: flex; align-items: center; gap: 12px; padding: 14px 16px;
               background: rgba(255,255,255,0.05); border-radius: 12px; margin: 8px 0;
               transition: all 0.2s; cursor: pointer; }
  .todo-item:hover { background: rgba(255,255,255,0.1); transform: translateX(4px); }
  .todo-item.done { opacity: 0.4; text-decoration: line-through; }
  .todo-check { width: 22px; height: 22px; border-radius: 50%; border: 2px solid #ffd200;
                 display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .todo-check.checked { background: #ffd200; color: #1a1a2e; }
  .todo-title { flex: 1; }
  .todo-cat { font-size: 0.75em; padding: 2px 8px; border-radius: 8px;
              background: rgba(255,255,255,0.1); color: #aaa; }
  .todo-pri { font-size: 0.7em; }
  .links { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #333; }
  .links a { color: #ffd200; text-decoration: none; margin: 0 12px; font-size: 0.9em; }
  .links a:hover { text-decoration: underline; }
  .empty { text-align: center; padding: 40px; color: #666; }
  .cat-icon { margin-right: 4px; }
</style>
</head>
<body>
<div class="container">
  <header>
    <h1>🗓️ Septober</h1>
    <p>Procrastinators unite... with better technology!</p>
  </header>
  <div class="stats">
    <div class="stat"><div class="stat-num" id="s-active">-</div><div class="stat-label">Active</div></div>
    <div class="stat"><div class="stat-num" id="s-done">-</div><div class="stat-label">Done</div></div>
    <div class="stat"><div class="stat-num" id="s-total">-</div><div class="stat-label">Total</div></div>
  </div>
  <form class="add-form" onsubmit="addTodo(event)">
    <input type="text" id="new-todo" placeholder="Aggiungi todo... (try: lavoro: prepare slides +)" autocomplete="off">
    <button type="submit">Add</button>
  </form>
  <ul class="todo-list" id="todo-list"></ul>
  <div class="links">
    <a href="/docs">📖 API Docs</a>
    <a href="/redoc">📕 ReDoc</a>
    <a href="/api/todos/">🔌 API</a>
    <a href="/healthz">💚 Health</a>
  </div>
</div>
<script>
const CAT_ICONS = {famiglia:'👨‍👩‍👧‍👦', personale:'🧘', lavoro:'💼', finanze:'🏦', shopping:'🛒'};
const PRI = {1:'○', 2:'◔', 3:'◑', 4:'◕', 5:'●'};

async function load() {
  try {
    const [active, done] = await Promise.all([
      fetch('/api/todos/?status=active&limit=50').then(r=>r.json()),
      fetch('/api/todos/?status=done&limit=50').then(r=>r.json()),
    ]);
    document.getElementById('s-active').textContent = active.total;
    document.getElementById('s-done').textContent = done.total;
    document.getElementById('s-total').textContent = active.total + done.total;
    const list = document.getElementById('todo-list');
    const items = [...active.items, ...done.items.slice(0,5)];
    if (!items.length) { list.innerHTML = '<div class="empty">Nessun todo! 🎉<br>Aggiungi il primo sopra.</div>'; return; }
    list.innerHTML = items.map(t => `
      <li class="todo-item ${t.status==='done'?'done':''}" onclick="toggle(${t.id})">
        <div class="todo-check ${t.status==='done'?'checked':''}">
          ${t.status==='done'?'✓':''}
        </div>
        <span class="todo-title">${esc(t.title)}</span>
        <span class="todo-pri">${PRI[t.priority]||'◑'}</span>
        <span class="todo-cat"><span class="cat-icon">${CAT_ICONS[t.category]||'🧘'}</span>${t.category}</span>
      </li>`).join('');
  } catch(e) { console.error(e); }
}

async function addTodo(e) {
  e.preventDefault();
  const input = document.getElementById('new-todo');
  const title = input.value.trim();
  if (!title) return;
  await fetch('/api/todos/', {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({title})});
  input.value = '';
  load();
}

async function toggle(id) {
  await fetch(`/api/todos/${id}/toggle`, {method:'POST'});
  load();
}

function esc(s) { const d=document.createElement('div'); d.textContent=s; return d.innerHTML; }
load();
</script>
</body>
</html>"""
    return HTMLResponse(content=html)


