# 🗓️ Septober Next

> "Procrastinators unite... with better technology!"

## What is Septober Next?

Septober Next is a modern rewrite of the 15-year-old Rails Septober app. It retains the magical, intuitive "magic parser" that made the original great, while bringing the architecture into the 2020s.

## Architecture

- **Backend:** FastAPI, Python 3.11+, SQLModel, SQLite
- **Frontend (Future):** Svelte PWA
- **Dependency Management:** `uv`

## Quick Start

```bash
# Install dependencies
uv sync

# Run the development server
just dev
```

Visit `http://localhost:8000/docs` to see the API documentation.

## The Magic Parser

The core of Septober is its magic parser. You can type tasks naturally, and the system extracts metadata:

- **Dates:** "buy milk today", "meeting tomorrow", "comprare latte oggi"
- **Priority:** "+important", "++critical", "-low priority", "urgent task!"
- **Tags:** "buy shoes @shopping @personal"
- **Categories:** "lavoro: prepare presentation"
- **Links:** "read this https://example.com"
- **Wishes:** "visit Japan #sogno" or "#wish"

## Categories

Categories are denoted by prefixes in the title (e.g., "lavoro: task"). Some common categories:
- 💼 Lavoro (Work)
- 🏠 Casa (Home)
- 👤 Personale (Personal)

## Wishes

Adding `#wish` or `#sogno` to a task marks it as a dream or wish—something you want to do, but without the pressure of a deadline.

## API Examples

You can interact with the API using tools like `curl`:

```bash
# Create a new todo with magic parsing
curl -X POST http://localhost:8000/api/todos \
    -H 'Content-Type: application/json' \
    -d '{"title": "+Buy milk tomorrow @shopping", "category": "personale"}'

# List todos
curl http://localhost:8000/api/todos

# Mark as done
curl -X POST http://localhost:8000/api/todos/{id}/done
```

## Legacy vs New

The original Rails app served faithfully for 15 years. Septober Next aims to improve:
- Type safety and modern Python features.
- A fast, decoupled API.
- Ease of deployment.

## Credits

Credits to the original Septober app for 15 years of solid procrastination management!
