"""Todo CRUD API endpoints with quick actions."""
import asyncio
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select, func, and_
from datetime import date, datetime, timedelta, timezone
from typing import Optional, List
from septober.models import Todo, Tag, TodoTagLink, TodoStatus, Category
from septober.schemas import TodoCreate, TodoUpdate, TodoRead, TodoList, StatsResponse
from septober.db import get_session
from septober.magic import apply_magic
from septober.broadcast import broadcaster


def _fire_event(event: str, data: dict | None = None):
    """Fire a WebSocket broadcast from a sync endpoint."""
    try:
        loop = asyncio.get_running_loop()
        loop.create_task(broadcaster.broadcast(event, data))
    except RuntimeError:
        pass  # No event loop — skip (e.g. in tests)


router = APIRouter(prefix="/api/todos", tags=["todos"])


def _now_utc() -> datetime:
    """Get current UTC datetime (timezone-aware)."""
    return datetime.now(timezone.utc)


def _get_or_create_tags(session: Session, tag_names: List[str]) -> List[Tag]:
    """Get existing tags or create new ones by name."""
    tags = []
    for name in tag_names:
        name = name.strip().lower()
        if not name:
            continue
        tag = session.exec(select(Tag).where(Tag.name == name)).first()
        if not tag:
            tag = Tag(name=name)
            session.add(tag)
            session.flush()
        tags.append(tag)
    return tags


def _todo_to_read(todo: Todo) -> TodoRead:
    """Convert a Todo ORM object to a TodoRead response."""
    tag_reads = [TagRead(id=t.id, name=t.name, color=t.color) for t in todo.tags] if todo.tags else []
    data = {
        "id": todo.id,
        "title": todo.title,
        "description": todo.description,
        "status": todo.status,
        "category": todo.category,
        "priority": todo.priority,
        "due": todo.due,
        "is_wish": todo.is_wish,
        "starred": todo.starred,
        "source": todo.source,
        "source_ref": todo.source_ref,
        "url": todo.url,
        "location": todo.location,
        "hide_until": todo.hide_until,
        "progress": todo.progress,
        "sys_notes": todo.sys_notes,
        "parent_id": todo.parent_id,
        "created_at": todo.created_at,
        "updated_at": todo.updated_at,
        "completed_at": todo.completed_at,
        "tags": tag_reads,
        "is_overdue": todo.is_overdue,
        "is_hidden": todo.is_hidden,
    }
    return TodoRead(**data)


from septober.schemas import TagRead


@router.get("/", response_model=TodoList)
def list_todos(
    status: Optional[TodoStatus] = None,
    category: Optional[Category] = None,
    is_wish: Optional[bool] = None,
    priority_min: Optional[int] = None,
    priority_max: Optional[int] = None,
    tag: Optional[str] = None,
    due_before: Optional[date] = None,
    due_after: Optional[date] = None,
    source: Optional[str] = None,
    search: Optional[str] = None,
    include_hidden: bool = False,
    offset: int = 0,
    limit: int = 50,
    sort_by: str = "priority",
    sort_order: str = "desc",
    session: Session = Depends(get_session),
):
    """List todos with filtering, sorting, and pagination."""
    query = select(Todo)

    if status:
        query = query.where(Todo.status == status)
    else:
        query = query.where(Todo.status == TodoStatus.active)

    if not include_hidden:
        now = _now_utc()
        query = query.where(
            (Todo.hide_until == None) | (Todo.hide_until <= now)  # noqa: E711
        )

    if category:
        query = query.where(Todo.category == category)
    if is_wish is not None:
        query = query.where(Todo.is_wish == is_wish)
    if priority_min is not None:
        query = query.where(Todo.priority >= priority_min)
    if priority_max is not None:
        query = query.where(Todo.priority <= priority_max)
    if due_before:
        query = query.where(Todo.due <= due_before)
    if due_after:
        query = query.where(Todo.due >= due_after)
    if source:
        query = query.where(Todo.source == source)
    if search:
        query = query.where(
            Todo.title.contains(search) | Todo.description.contains(search)
        )

    if tag:
        tag_names = [t.strip() for t in tag.split(",")]
        query = query.join(TodoTagLink).join(Tag).where(Tag.name.in_(tag_names))

    # Total count
    total = session.exec(select(func.count()).select_from(query.subquery())).one()

    # Sorting
    sort_col = getattr(Todo, sort_by, Todo.priority)
    if sort_order == "desc":
        sort_col = sort_col.desc()
    query = query.order_by(sort_col).offset(offset).limit(limit)

    todos = session.exec(query).all()
    items = [_todo_to_read(t) for t in todos]
    return TodoList(items=items, total=total)


@router.post("/", response_model=TodoRead, status_code=201)
def create_todo(todo_in: TodoCreate, session: Session = Depends(get_session)):
    """Create a new todo with magic regex parsing."""
    magic = apply_magic(todo_in.title)

    # Build the Todo, preferring explicit user values over magic-parsed ones
    todo = Todo(
        title=magic.title,
        description=todo_in.description,
        category=Category(magic.category) if magic.category and magic.category in [c.value for c in Category] else todo_in.category,
        priority=magic.priority if magic.priority is not None else todo_in.priority,
        due=todo_in.due if todo_in.due is not None else magic.due,
        is_wish=magic.is_wish or todo_in.is_wish,
        source=todo_in.source,
        source_ref=todo_in.source_ref,
        url=todo_in.url or magic.url,
        location=todo_in.location,
        sys_notes="\n".join(magic.logs) if magic.logs else None,
    )

    session.add(todo)
    session.commit()
    session.refresh(todo)

    # Handle tags: from magic parsing + explicit tags from request
    all_tag_names = list(set(magic.tags + todo_in.tags))
    if all_tag_names:
        tags = _get_or_create_tags(session, all_tag_names)
        for t in tags:
            link = TodoTagLink(todo_id=todo.id, tag_id=t.id)
            session.add(link)
        session.commit()
        session.refresh(todo)

    result = _todo_to_read(todo)
    _fire_event("todo_created", {"id": todo.id, "title": todo.title})
    return result


@router.get("/{todo_id}", response_model=TodoRead)
def get_todo(todo_id: int, session: Session = Depends(get_session)):
    """Get a single todo by ID."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return _todo_to_read(todo)


@router.patch("/{todo_id}", response_model=TodoRead)
def update_todo(
    todo_id: int, todo_in: TodoUpdate, session: Session = Depends(get_session)
):
    """Partially update a todo."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")

    update_data = todo_in.model_dump(exclude_unset=True, exclude={"tags"})

    # Handle status transitions
    if "status" in update_data:
        if update_data["status"] == TodoStatus.done and todo.status != TodoStatus.done:
            todo.completed_at = _now_utc()
        elif update_data["status"] == TodoStatus.active:
            todo.completed_at = None

    for key, value in update_data.items():
        setattr(todo, key, value)

    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return _todo_to_read(todo)


@router.delete("/{todo_id}", status_code=204)
def delete_todo(todo_id: int, session: Session = Depends(get_session)):
    """Hard-delete a todo."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    session.delete(todo)
    session.commit()
    _fire_event("todo_deleted", {"id": todo_id})


@router.post("/{todo_id}/done", response_model=TodoRead)
def mark_done(todo_id: int, session: Session = Depends(get_session)):
    """Mark a todo as done (swipe left action)."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    todo.status = TodoStatus.done
    todo.completed_at = _now_utc()
    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return _todo_to_read(todo)


@router.post("/{todo_id}/undone", response_model=TodoRead)
def mark_undone(todo_id: int, session: Session = Depends(get_session)):
    """Reactivate a completed todo."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    todo.status = TodoStatus.active
    todo.completed_at = None
    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return _todo_to_read(todo)


@router.post("/{todo_id}/toggle", response_model=TodoRead)
def toggle_todo(todo_id: int, session: Session = Depends(get_session)):
    """Toggle todo between active and done."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    if todo.status == TodoStatus.done:
        todo.status = TodoStatus.active
        todo.completed_at = None
    else:
        todo.status = TodoStatus.done
        todo.completed_at = _now_utc()
    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    result = _todo_to_read(todo)
    _fire_event("todo_toggled", {"id": todo.id, "status": todo.status.value})
    return result


@router.post("/{todo_id}/snooze", response_model=TodoRead)
def snooze_todo(
    todo_id: int, days: int = 7, session: Session = Depends(get_session)
):
    """Snooze a todo — hide it for N days (swipe right action)."""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    todo.hide_until = _now_utc() + timedelta(days=days)
    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return _todo_to_read(todo)


@router.post("/{todo_id}/procrastinate", response_model=TodoRead)
def procrastinate_todo(todo_id: int, session: Session = Depends(get_session)):
    """Classic Septober procrastinate: push due date +7 days. 🦥"""
    todo = session.get(Todo, todo_id)
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    if todo.due:
        todo.due = todo.due + timedelta(days=7)
    else:
        todo.due = date.today() + timedelta(days=7)
    todo.updated_at = _now_utc()
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return _todo_to_read(todo)


@router.get("/stats", response_model=StatsResponse)
def get_stats(session: Session = Depends(get_session)):
    """Get overview statistics."""
    total = session.exec(select(func.count(Todo.id))).one()
    active = session.exec(
        select(func.count(Todo.id)).where(Todo.status == TodoStatus.active)
    ).one()
    done_count = session.exec(
        select(func.count(Todo.id)).where(Todo.status == TodoStatus.done)
    ).one()
    wishes = session.exec(
        select(func.count(Todo.id)).where(Todo.is_wish == True)  # noqa: E712
    ).one()
    overdue = session.exec(
        select(func.count(Todo.id)).where(
            and_(Todo.due < date.today(), Todo.status == TodoStatus.active)
        )
    ).one()

    return StatsResponse(
        total=total,
        active=active,
        done=done_count,
        wishes=wishes,
        overdue=overdue,
    )
