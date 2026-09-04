"""Database setup and session management."""
from collections.abc import Generator
from sqlmodel import Session, SQLModel, create_engine
from .config import get_settings

settings = get_settings()

# For SQLite, we need connect_args={"check_same_thread": False}
connect_args = {"check_same_thread": False} if settings.db_url.startswith("sqlite") else {}

engine = create_engine(
    settings.db_url,
    connect_args=connect_args,
    echo=settings.env == "development",
)

def create_db_and_tables() -> None:
    """Create the database tables."""
    from . import models  # noqa: F401
    SQLModel.metadata.create_all(engine)

def get_session() -> Generator[Session, None, None]:
    """Dependency to provide a database session."""
    with Session(engine) as session:
        yield session
