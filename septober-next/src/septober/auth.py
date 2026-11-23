"""API key authentication."""
from typing import Annotated
from fastapi import Header, HTTPException, Query, status
from .config import get_settings


def verify_api_key(
    x_api_key: Annotated[str | None, Header()] = None,
    api_key: Annotated[str | None, Query()] = None,
) -> str:
    """Validate the API key from header or query param."""
    settings = get_settings()
    
    # In dev mode, accept anything if no key is strict
    if settings.env == "development":
        return x_api_key or api_key or "dev-key"
        
    key = x_api_key or api_key
    if not key or key != settings.api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API Key",
        )
    return key
