FROM python:3.12-slim

WORKDIR /app

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files
COPY pyproject.toml uv.lock README.md ./
COPY src/ src/

# Install dependencies (no dev extras needed for prod)
RUN uv sync --no-dev --frozen

# Expose port (Cloud Run sets PORT env var)
EXPOSE 8080

# Run with uvicorn, respect PORT env var from Cloud Run
CMD ["uv", "run", "uvicorn", "septober.main:app", "--host", "0.0.0.0", "--port", "8080"]
