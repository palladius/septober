"""Configuration management for Septober."""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings, populated via environment variables."""
    api_key: str = 'dev-key-change-me'
    db_url: str = 'sqlite:///septober.db'
    host: str = '0.0.0.0'
    port: int = 8000
    env: str = 'development'
    app_name: str = 'Septober Next'
    version: str = '3.0.0'
    default_procrastination_days: int = 7

    # Obsidian sync settings
    gemini_api_key: str = ''  # Required for obsidian sync, not for server
    api_url: str = 'http://localhost:8000'
    obpbt_cmd: str = 'obpbt todos'
    stale_days: int = 14
    gemini_model: str = 'gemini-2.0-flash'

    model_config = SettingsConfigDict(
        env_prefix='SEPTOBER_',
        env_file='.env',
        env_file_encoding='utf-8',
        extra='ignore'
    )


@lru_cache
def get_settings() -> Settings:
    """Get cached settings."""
    return Settings()
