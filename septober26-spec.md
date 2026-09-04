# Septober Revival & Living Todos Spec
## Revamping Riccardo's RoR Engine as the Context-Aware Backend

**Authors:** Riccardo Carlesso & Ermete Bottazzi 🪽🚛  
**Status:** DRAFT / REVIVAL RFC  
**Date:** 2026-09-03  
**Repo:** `~/git/septober`  
**Cloud Infrastructure:** GCP Project `7eptober` (Cloud Run + Cloud SQL MySQL)  

---

## 1. Executive Summary

Riccardo's legendary 2011 Ruby on Rails application, **Septober**, was built ahead of its time. Its data model already possesses almost the exact schema needed for **Context-Aware ("Living") To-Dos**:
- `name` (Title)
- `description` (Context narrative & background)
- `where` (Location or entity: e.g. "Lido degli Estensi", "GDG Zurich")
- `url` (Context reference link)
- `due` (Due date)
- `priority` (1-5 scale)
- `tags` / `taggings` (Polymorphic tagging system)
- `projects` (Categorization with home visibility)
- `sys_notes` (Agent metadata / prompt lineage)
- `source` (e.g. `ermete_telegram`, `cli`)

Instead of inventing a new database from scratch, **the true dependency and highest-leverage task is to revamp Septober**:
1. Fix/modernize the **Cloud Run** deployment in GCP project `7eptober`.
2. Connect cleanly to the existing **Cloud SQL** MySQL instance.
3. Build a **Hermes Agent Skill (`septober`)** so Ermete can populate rich, context-dense todos directly from Telegram voice/text.
4. Consume via existing/updated `septober-cli` and web UI when sitting at the desk at work.

---

## 2. Infrastructure & Cloud Run Revamp Plan

### 2.1 Existing Cloud Setup
- **GCP Project:** `7eptober`
- **Database:** Cloud SQL MySQL (`septober` DB, user `septoberuser`, IP `35.198.182.127`)
- **Docker Image:** `gcr.io/7eptober/septober-ng` (Ruby/Rails runtime + entrypoint-8080.sh)
- **Target Service:** Cloud Run (`septober-mysql` or `septober-app`)

### 2.2 Why Cloud Run was Broken / Remediation Steps
1. **Cloud SQL Connection:** Cloud Run needs `--add-cloudsql-instances` or Cloud SQL Unix socket path (`/cloudsql/7eptober:<region>:<instance>`), or direct VPC connector / authorized IP access.
2. **Port & Health Check:** Ensure `PORT=8080` is respected by `entrypoint-8080.sh` and unicorn/thin/webrick listens on `0.0.0.0:8080`.
3. **Environment Secrets:** Pass `DATABASE_HOST`, `DATABASE_PASSWORD`, `SECRET_KEY_BASE` securely via Cloud Secret Manager or environment variables.
4. **Deploy Command Example:**
   ```bash
   gcloud run deploy septober \
     --project 7eptober \
     --image gcr.io/7eptober/septober-ng:latest \
     --region europe-west1 \
     --platform managed \
     --allow-unauthenticated \
     --set-env-vars RAILS_ENV=production,DATABASE_HOST=35.198.182.127,DATABASE_NAME=septober,DATABASE_USER=septoberuser \
     --set-secrets DATABASE_PASSWORD=septober-db-password:latest
   ```

---

## 3. Data Mapping: How Ermete Enriches To-Dos

When Riccardo says:
> *"Ermete, stasera ho il talk al GDG, devo rivedere le slide e controllare che la demo di Vertex non spacchi i limiti."*

Ermete transforms this into a Septober API payload:
```json
{
  "todo": {
    "name": "Rivedere slide talk GDG e testare demo Vertex",
    "due": "2026-09-03",
    "priority": 2,
    "where": "GDG Zurich",
    "url": "https://docs.google.com/presentation/d/...",
    "description": "Talk di stasera al GDG sulle architetture agentiche SRE. Verificare che la demo live non vada in 429 quota exhaustion e ricontrollare le slide 12-14.",
    "source": "ermete_voice",
    "sys_notes": "Prompt origin: Telegram voice note 2026-09-03 09:39"
  },
  "tags": ["lavoro", "google", "tech", "gdg", "presentation"]
}
```

---

## 4. Hermes Skill: `septober-todo`

### 4.1 Actions
- `septober_add(name, description, due, priority, where, url, tags, project)`
- `septober_list(status, due, tag)`
- `septober_done(id)`

### 4.2 Auth & Endpoint
Configured via `~/.septober.yml` (already familiar to `bin/septober-cli`):
```yaml
production:
  site: https://septober-xxxxx.a.run.app/api/
  user: rcarlesso
  password: <pwd>
```

---

## 5. Next Execution Steps

1. **Inspect Cloud Run service state in `7eptober`** via `gcloud run services list --project 7eptober`.
2. **Verify Cloud SQL database status** in `7eptober`.
3. **Test local container run** with `./docker-run-septober-mysql-prod` to verify Rails boots and DB connects.
4. **Deploy updated revision to Cloud Run**.
5. **Implement Hermes skill** for Ermete to talk to Septober.
