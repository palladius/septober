"""Pydantic schemas for API requests and responses."""
from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict

from .models import Category, TodoStatus


class TagBase(BaseModel):
    name: str
    color: str | None = None


class TagCreate(TagBase):
    pass


class TagRead(TagBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    todo_count: int | None = None


class TodoBase(BaseModel):
    title: str = Field(..., max_length=500)
    description: str | None = None
    category: Category = Category.personale
    priority: int = Field(default=3, ge=1, le=5)
    due: date | None = None
    is_wish: bool = False
    source: str = "web"
    source_ref: str | None = None
    url: str | None = None
    location: str | None = None


class TodoCreate(TodoBase):
    tags: list[str] = []


class TodoUpdate(BaseModel):
    title: str | None = Field(default=None, max_length=500)
    description: str | None = None
    status: TodoStatus | None = None
    category: Category | None = None
    priority: int | None = Field(default=None, ge=1, le=5)
    due: date | None = None
    is_wish: bool | None = None
    source: str | None = None
    source_ref: str | None = None
    url: str | None = None
    location: str | None = None
    tags: list[str] | None = None


class TodoRead(BaseModel):
    """Full todo response with computed fields."""
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str | None = None
    status: TodoStatus
    category: Category
    priority: int
    due: date | None = None
    is_wish: bool
    starred: bool
    source: str
    source_ref: str | None = None
    url: str | None = None
    location: str | None = None
    hide_until: datetime | None = None
    progress: int
    sys_notes: str | None = None
    parent_id: int | None = None
    created_at: datetime
    updated_at: datetime
    completed_at: datetime | None = None
    tags: list[TagRead] = []

    is_overdue: bool = False
    is_hidden: bool = False


class TodoList(BaseModel):
    items: list[TodoRead]
    total: int


class BulkIngestRequest(BaseModel):
    items: list[TodoCreate]
    source: str = "bulk_api"


class BulkIngestResponse(BaseModel):
    created_count: int
    errors: list[str]


class StatsResponse(BaseModel):
    total: int
    active: int
    done: int
    wishes: int
    overdue: int
