"""Septober data models using SQLModel (SQLAlchemy + Pydantic)."""
from datetime import datetime, date, timezone
from enum import Enum
from sqlmodel import SQLModel, Field, Relationship


class TodoStatus(str, Enum):
    """Todo lifecycle status."""
    active = "active"
    done = "done"
    archived = "archived"


class Category(str, Enum):
    """Primary life category for todos."""
    famiglia = "famiglia"      # Family, kids, wife
    personale = "personale"    # Personal, health, hobbies
    lavoro = "lavoro"          # Work, DevRel, conferences
    finanze = "finanze"        # Banks, taxes, house, important docs
    shopping = "shopping"      # Shopping list, wish list


# --- Link table for many-to-many Todo <-> Tag ---
class TodoTagLink(SQLModel, table=True):
    """Many-to-many relationship between Todos and Tags."""
    __tablename__ = "todo_tag"
    todo_id: int = Field(foreign_key="todo.id", primary_key=True)
    tag_id: int = Field(foreign_key="tag.id", primary_key=True)


class Tag(SQLModel, table=True):
    """A label/tag that can be applied to multiple todos."""
    __tablename__ = "tag"
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(unique=True, index=True, max_length=100)
    color: str | None = Field(default=None, max_length=20)
    
    # Relationships
    todos: list["Todo"] = Relationship(back_populates="tags", link_model=TodoTagLink)


class Todo(SQLModel, table=True):
    """The main Todo entity — the heart of Septober."""
    __tablename__ = "todo"
    id: int | None = Field(default=None, primary_key=True)
    
    # Core fields
    title: str = Field(index=True, max_length=500)
    description: str | None = Field(default=None)
    status: TodoStatus = Field(default=TodoStatus.active, index=True)
    
    # Organization
    category: Category = Field(default=Category.personale, index=True)
    is_wish: bool = Field(default=False, description="Dream/someday item vs actionable todo")
    priority: int = Field(default=3, ge=1, le=5, description="1=lowest, 5=highest")
    starred: bool = Field(default=False, description="Bookmarked/favorite")
    
    # Timing
    due: date | None = Field(default=None, index=True)
    hide_until: datetime | None = Field(default=None, description="Snooze: hidden until this datetime")
    
    # Progress
    progress: int = Field(default=0, ge=0, le=100, description="Completion percentage")
    
    # Source tracking (for multi-source ingestion)
    source: str = Field(default="web", max_length=50, description="Origin: web, cli, agent, obsidian, voice, email")
    source_ref: str | None = Field(default=None, max_length=500, description="Reference to original source")
    
    # Metadata
    url: str | None = Field(default=None, max_length=2000)
    location: str | None = Field(default=None, max_length=500, description="Where this todo is relevant")
    sys_notes: str | None = Field(default=None, description="System/debug notes, agent logs")
    
    # Hierarchy
    parent_id: int | None = Field(default=None, foreign_key="todo.id", description="Parent todo for subtasks")
    
    # Timestamps
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    completed_at: datetime | None = Field(default=None, description="When this todo was marked done")
    
    # Relationships
    tags: list[Tag] = Relationship(back_populates="todos", link_model=TodoTagLink)

    @property
    def is_overdue(self) -> bool:
        """Check if the todo is overdue."""
        if not self.due or self.status != TodoStatus.active:
            return False
        return self.due < date.today()

    @property
    def is_hidden(self) -> bool:
        """Check if the todo is hidden/snoozed."""
        if not self.hide_until:
            return False
        # If hide_until is naive, compare with naive now; if aware, with aware now
        return self.hide_until > datetime.now(timezone.utc)
