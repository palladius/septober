"""Obsidian vault scanner and intelligent todo extractor for Septober.

Parses `obpbt todos` output or raw markdown files, classifies each item as
ACTIONABLE / STALE / NOISE / REFERENCE, maps to Septober categories, and
can ingest into the Septober API.

The key insight: most "TODOs" in Obsidian are NOT real actionable tasks.
This module is ruthlessly selective — only genuine tasks survive.
"""

import re
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from enum import Enum
from typing import Optional


class Verdict(str, Enum):
    """Classification of an Obsidian todo item."""
    ACTIONABLE = "actionable"   # Real task, ingest into Septober
    STALE = "stale"             # Was actionable, now past its date
    NOISE = "noise"             # Bare "TODO", fragments, not a real task
    REFERENCE = "reference"     # A link/video/doc — maybe a wish, not a task
    BORDERLINE = "borderline"   # Ambiguous — needs LLM triage
    DONE = "done"               # Already completed
    EXPENSE = "expense"         # Expense tracking item, not a todo


# Emoji → category + context mapping
EMOJI_CATEGORY_MAP = {
    # Travel/work trips
    "🇩🇪": "lavoro",
    "🏛": "lavoro",
    "🔵": "lavoro",
    # Personal/family
    "🏖️": "famiglia",
    "🦟": "famiglia",
    "👨‍👩‍👧‍👦": "famiglia",
    # Italy trips (could be either)
    "🍕": "lavoro",     # Default to lavoro for organized trips
    "🇮🇹": None,        # Ambiguous, use other signals
    # Shopping/home
    "🛒": "shopping",
    "🏠": "personale",
}

# Tags → category mapping
TAG_CATEGORY_MAP = {
    "casa": "finanze",
    "tech": "personale",
    "foto": "famiglia",
    "lavoro": "lavoro",
    "personale": "personale",
    "sabatodo": "personale",
    "shopping": "shopping",
    "family": "famiglia",
    "salute": "personale",
    "health": "personale",
}

# Priority emoji mapping
PRIORITY_EMOJI_MAP = {
    "🔴": 5,   # High/urgent
    "🟠": 4,   # Medium-high
    "🟡": 3,   # Medium
    "🟢": 2,   # Low
    "⏫": 5,   # Obsidian highest priority
    "🔼": 4,   # Obsidian high
}


@dataclass
class ObsidianTodo:
    """A parsed todo item from Obsidian / obpbt output."""
    raw_line: str
    date: Optional[date] = None
    status: str = "open"          # open, done, idea
    hash_id: str = ""
    starred: bool = False
    title: str = ""
    tags: list[str] = field(default_factory=list)
    source_file: str = ""
    source_line: int = 0
    priority_emoji: str = ""
    context_emojis: list[str] = field(default_factory=list)

    # Classification results
    verdict: Verdict = Verdict.NOISE
    verdict_reason: str = ""
    septober_category: str = "personale"
    septober_priority: int = 3
    septober_is_wish: bool = False
    septober_url: Optional[str] = None


def parse_obpbt_line(line: str) -> Optional[ObsidianTodo]:
    """Parse a single line from `obpbt todos` output.

    Format: DATE  [STAR] STATUS  #HASH  CONTENT  (FILE:LINE)
    Example: 2026-08-18  ⭐ [ ]  #5480748  🟠 Installare app TV7  (TODOs/TODOz.md:4)
    """
    # Strip ANSI color codes
    line = re.sub(r'\x1b\[[0-9;]*m', '', line).strip()
    if not line:
        return None

    todo = ObsidianTodo(raw_line=line)

    # Parse date at start
    date_match = re.match(r'^(\d{4}-\d{2}-\d{2})', line)
    if not date_match:
        return None
    try:
        todo.date = datetime.strptime(date_match.group(1), "%Y-%m-%d").date()
    except ValueError:
        return None

    rest = line[len(date_match.group(0)):].strip()

    # Check starred
    if '⭐' in rest:
        todo.starred = True
        rest = rest.replace('⭐', '').strip()

    # Parse status
    if '[ ]' in rest:
        todo.status = "open"
    elif '[x]' in rest:
        todo.status = "done"
    elif '💡' in rest:
        todo.status = "idea"
    else:
        todo.status = "unknown"

    # Remove status marker
    rest = re.sub(r'\[[ x]\]|💡', '', rest).strip()

    # Parse hash
    hash_match = re.search(r'#([0-9a-f]{7})', rest)
    if hash_match:
        todo.hash_id = hash_match.group(1)
        rest = rest[:hash_match.start()] + rest[hash_match.end():]
        rest = rest.strip()

    # Parse source file (at the end in parentheses)
    source_match = re.search(r'\(([^)]+\.md):(\d+)\)\s*$', rest)
    if source_match:
        todo.source_file = source_match.group(1)
        todo.source_line = int(source_match.group(2))
        rest = rest[:source_match.start()].strip()

    # Extract priority emoji
    for emoji, priority in PRIORITY_EMOJI_MAP.items():
        if emoji in rest:
            todo.priority_emoji = emoji
            todo.septober_priority = priority
            rest = rest.replace(emoji, '').strip()
            break

    # Extract context emojis (travel/context indicators)
    for emoji in EMOJI_CATEGORY_MAP:
        if emoji in rest:
            todo.context_emojis.append(emoji)

    # Extract tags (#word)
    tag_matches = re.findall(r'#(\w[\w-]*)', rest)
    todo.tags = [t for t in tag_matches if len(t) < 30 and not re.match(r'^[0-9a-f]{7}$', t)]

    # Extract URL
    url_match = re.search(r'(https?://\S+)', rest)
    if url_match:
        todo.septober_url = url_match.group(1)

    # Clean title: remove tag markers, clean up whitespace
    title = rest
    title = re.sub(r'#\w[\w-]*', '', title)  # Remove #tags
    title = re.sub(r'\s+', ' ', title).strip()
    todo.title = title

    return todo


def classify_todo(todo: ObsidianTodo) -> ObsidianTodo:
    """Apply intelligent classification to determine if this todo is worth ingesting.

    This is the BRAIN of the filter — be ruthlessly selective!
    """
    today = date.today()
    title_lower = todo.title.lower().strip()

    # === DONE items: skip ===
    if todo.status == "done":
        todo.verdict = Verdict.DONE
        todo.verdict_reason = "Already completed"
        return todo

    # === NOISE: bare "TODO" with no real content ===
    clean_title = re.sub(r'[^\w\s]', '', title_lower).strip()
    if clean_title in ('todo', 'todo)', '', 'tbd'):
        todo.verdict = Verdict.NOISE
        todo.verdict_reason = "Bare 'TODO' placeholder — no real content"
        return todo

    if len(clean_title) < 5:
        todo.verdict = Verdict.NOISE
        todo.verdict_reason = f"Too short ({len(clean_title)} chars) — not a real task"
        return todo

    # Vague TODOs: "TODO - section header", "TODO in something", "TODO for X."
    # These are notes/headers in markdown, not actionable tasks
    vague_todo_pattern = re.match(
        r'^todo[\s:_`\-]*(?:'
        r'[\-–—]\s*\w|'           # "TODO - Something" (section header)
        r'in\s+\w|'               # "TODO in Obsidian" (note about location)
        r'for\s+\w|'              # "TODO for UK ETA" (vague reminder)
        r'lists?\s|'              # "TODO lists moved under..." (meta-note)
        r'comments?\s|'           # "TODO comments dynamically..." (meta)
        r'guarda\w*\s*$|'         # "TODO guardaci" (too vague, no object)
        r'to\s+verify|'           # "TODO to verify..." (meta observation)
        r'\(da\s|'                # "TODO (da redigere..." (parenthetical)
        r'\(harness\)|'           # "TODO(harness):" (code-style TODO)
        r'sbobinare\s*$|'         # Single vague verb with no clear object
        r'domani\s+\w+\s+\w+$|'  # "TODO domani gmail..." (stream of consciousness)
        r'prova\s'                # "TODO prova..." (test/experiment)
        r')',
        clean_title, re.IGNORECASE
    )
    if vague_todo_pattern and not todo.starred:
        todo.verdict = Verdict.NOISE
        todo.verdict_reason = "Vague TODO note/header — not a specific actionable task"
        return todo

    # Code/config command notes embedded in markdown
    if re.match(r'^todo[\s:`]*(?:ln\s|mv\s|cp\s|rm\s|cd\s|git\s)', clean_title, re.IGNORECASE):
        todo.verdict = Verdict.NOISE
        todo.verdict_reason = "Code/config snippet — not a personal task"
        return todo

    # === EXPENSE items: things that look like expense tracking ===
    expense_signals = ['€', 'eur', 'chf', '#gcard', '#itemized', '#da-expensare',
                       'caffè', 'taxi', 'uber', 'hotel booking', 'sbb', 'biglietto']
    expense_score = sum(1 for s in expense_signals if s in title_lower or s in [t.lower() for t in todo.tags])
    if expense_score >= 2:
        todo.verdict = Verdict.EXPENSE
        todo.verdict_reason = f"Expense tracking item ({expense_score} expense signals)"
        return todo

    # === REFERENCE: just a link/video/doc with no action verb ===
    action_verbs_it = ['prenotare', 'comprare', 'installare', 'organizzare', 'verificare',
                       'porta', 'riporta', 'definire', 'sbobinare', 'trasferire',
                       'preparare', 'fare', 'mandare', 'inviare', 'chiamare', 'pulire',
                       'controllare', 'aggiornare', 'scrivere', 'creare']
    action_verbs_en = ['book', 'buy', 'install', 'organize', 'verify', 'prepare',
                       'create', 'send', 'call', 'clean', 'update', 'write', 'check',
                       'fix', 'setup', 'configure', 'schedule', 'review', 'add']

    has_action = any(v in title_lower for v in action_verbs_it + action_verbs_en)
    has_url = todo.septober_url is not None

    if has_url and not has_action and not todo.starred:
        # It's just a link dump, not a real task
        # But might be a useful reference → wish mode
        todo.verdict = Verdict.REFERENCE
        todo.verdict_reason = "URL/link without action verb — saved as wish/reference"
        todo.septober_is_wish = True
        # Still worth importing as a reference, so we'll mark it actionable below
        # only if it has other strong signals

    # === STALE: past-dated travel prep that's clearly over ===
    if todo.date and todo.date < today - timedelta(days=14):
        # Check if it's travel prep (prenotare, book, etc.)
        travel_prep_words = ['prenotare', 'book', 'check-in', 'volo', 'treno',
                             'hotel', 'bagaglio', 'partenza']
        is_travel_prep = any(w in title_lower for w in travel_prep_words)

        # Check if it's from a dated travel note
        is_travel_note = re.match(r'^\d{8}\s+Viaggio', todo.source_file)

        if (is_travel_prep or is_travel_note) and not todo.starred:
            todo.verdict = Verdict.STALE
            todo.verdict_reason = f"Travel prep from {todo.date} — trip is over"
            return todo

        # Generic stale items (old and not starred)
        if todo.date < today - timedelta(days=60) and not todo.starred:
            todo.verdict = Verdict.STALE
            todo.verdict_reason = f"Old item from {todo.date} ({(today - todo.date).days}d ago)"
            return todo

    # === If we got here and it's a reference, keep as wish ===
    if todo.verdict == Verdict.REFERENCE:
        return todo

    # === BORDERLINE: items that are ambiguous — needs LLM triage ===
    # Items starting with 'TODO' followed by meaningful content but no clear action verb
    is_todo_prefix = clean_title.startswith('todo')
    has_substantial_text = len(clean_title) > 20
    
    if is_todo_prefix and not has_action and has_substantial_text and not todo.starred:
        todo.verdict = Verdict.BORDERLINE
        todo.verdict_reason = "Ambiguous TODO — needs LLM triage"
        return todo
    
    # Items with no action verb, no stars, no priority emoji, but substantial content
    if not has_action and not todo.starred and not todo.priority_emoji and has_substantial_text:
        todo.verdict = Verdict.BORDERLINE  
        todo.verdict_reason = "No action verb or priority signal — needs LLM triage"
        return todo

    # === ACTIONABLE: everything else with real content ===
    todo.verdict = Verdict.ACTIONABLE
    reasons = []
    if todo.starred:
        reasons.append("starred ⭐")
        todo.septober_priority = max(todo.septober_priority, 4)
    if has_action:
        reasons.append("has action verb")
    if todo.date and todo.date >= today:
        reasons.append(f"future-dated ({todo.date})")
    todo.verdict_reason = ", ".join(reasons) if reasons else "real task content"

    # === Category mapping ===
    # 1. Try emoji context
    for emoji in todo.context_emojis:
        cat = EMOJI_CATEGORY_MAP.get(emoji)
        if cat:
            todo.septober_category = cat
            break

    # 2. Try tag mapping (overrides emoji if more specific)
    for tag in todo.tags:
        cat = TAG_CATEGORY_MAP.get(tag.lower())
        if cat:
            todo.septober_category = cat
            break

    # 3. Source file heuristics
    sf = todo.source_file.lower()
    if 'viaggio' in sf or 'travel' in sf:
        if 'famiglia' in sf or 'family' in sf or 'lido' in sf or 'estensi' in sf:
            todo.septober_category = "famiglia"
        elif 'devfest' in sf or 'wad' in sf or 'summit' in sf or 'biondi' in sf:
            todo.septober_category = "lavoro"
    elif 'family' in sf or 'famiglia' in sf:
        todo.septober_category = "famiglia"
    elif 'case' in sf or 'casa' in sf:
        todo.septober_category = "finanze"
    elif 'hobbies' in sf:
        todo.septober_category = "personale"

    return todo


def parse_and_classify(raw_output: str) -> list[ObsidianTodo]:
    """Parse full obpbt output and classify every item."""
    todos = []
    for line in raw_output.splitlines():
        todo = parse_obpbt_line(line)
        if todo:
            todo = classify_todo(todo)
            todos.append(todo)
    return todos


def format_report(todos: list[ObsidianTodo]) -> str:
    """Generate a human-readable classification report."""
    lines = []

    # Group by verdict
    by_verdict: dict[Verdict, list[ObsidianTodo]] = {}
    for t in todos:
        by_verdict.setdefault(t.verdict, []).append(t)

    # Summary
    lines.append("=" * 70)
    lines.append("🧹 SEPTOBER OBSIDIAN FILTER — CLASSIFICATION REPORT")
    lines.append("=" * 70)
    lines.append(f"Total items scanned: {len(todos)}")
    lines.append("")
    for v in [Verdict.ACTIONABLE, Verdict.BORDERLINE, Verdict.REFERENCE, Verdict.STALE, Verdict.NOISE, Verdict.EXPENSE, Verdict.DONE]:
        count = len(by_verdict.get(v, []))
        emoji = {"actionable": "✅", "borderline": "🤔", "stale": "⏰", "noise": "🗑️",
                 "reference": "📎", "done": "☑️", "expense": "💰"}.get(v.value, "?")
        lines.append(f"  {emoji} {v.value.upper():12s}: {count:3d}")
    lines.append("")

    # Actionable items (the GOLD)
    actionable = by_verdict.get(Verdict.ACTIONABLE, [])
    if actionable:
        lines.append("=" * 70)
        lines.append("✅ ACTIONABLE — These will be ingested into Septober:")
        lines.append("=" * 70)
        for t in actionable:
            star = "⭐" if t.starred else "  "
            cat_icons = {"famiglia": "👨‍👩‍👧‍👦", "personale": "🧘", "lavoro": "💼",
                         "finanze": "🏦", "shopping": "🛒"}.get(t.septober_category, "?")
            p_dots = "●" * t.septober_priority + "○" * (5 - t.septober_priority)
            tags_str = " ".join(f"#{t}" for t in t.tags[:3]) if t.tags else ""
            lines.append(f"  {star} {cat_icons} [{p_dots}] {t.title[:70]}")
            lines.append(f"       📁 {t.source_file}  {tags_str}")
            lines.append(f"       💬 {t.verdict_reason}")
            lines.append("")

    # Borderline items
    borderline = by_verdict.get(Verdict.BORDERLINE, [])
    if borderline:
        lines.append("-" * 70)
        lines.append(f"🤔 BORDERLINE — Needs LLM triage ({len(borderline)} items):")
        lines.append("-" * 70)
        for t in borderline:
            lines.append(f"  🤔 {t.title[:60]} — {t.verdict_reason}")
        lines.append("")

    # References (wishes)
    refs = by_verdict.get(Verdict.REFERENCE, [])
    if refs:
        lines.append("-" * 70)
        lines.append("📎 REFERENCES — Saved as wishes/sogni nel cassetto:")
        lines.append("-" * 70)
        for t in refs:
            lines.append(f"  💭 {t.title[:70]}")
            lines.append(f"       🔗 {t.septober_url or 'no url'}")
            lines.append("")

    # Stale (skipped)
    stale = by_verdict.get(Verdict.STALE, [])
    if stale:
        lines.append("-" * 70)
        lines.append(f"⏰ STALE — Skipped ({len(stale)} items):")
        lines.append("-" * 70)
        for t in stale[:5]:
            lines.append(f"  ⏰ {t.title[:60]} — {t.verdict_reason}")
        if len(stale) > 5:
            lines.append(f"  ... and {len(stale) - 5} more")
        lines.append("")

    # Noise (skipped)
    noise = by_verdict.get(Verdict.NOISE, [])
    if noise:
        lines.append("-" * 70)
        lines.append(f"🗑️  NOISE — Skipped ({len(noise)} items):")
        lines.append("-" * 70)
        for t in noise[:5]:
            lines.append(f"  🗑️  \"{t.title[:50]}\" — {t.verdict_reason}")
        if len(noise) > 5:
            lines.append(f"  ... and {len(noise) - 5} more")
        lines.append("")

    # Expense (skipped)
    expenses = by_verdict.get(Verdict.EXPENSE, [])
    if expenses:
        lines.append("-" * 70)
        lines.append(f"💰 EXPENSES — Skipped ({len(expenses)} items, not real TODOs):")
        lines.append("-" * 70)
        for t in expenses[:3]:
            lines.append(f"  💰 \"{t.title[:60]}\"")
        if len(expenses) > 3:
            lines.append(f"  ... and {len(expenses) - 3} more")

    done_count = len(by_verdict.get(Verdict.DONE, []))
    lines.append("")
    lines.append(f"☑️  DONE: {done_count} completed items silently skipped")

    return "\n".join(lines)


def to_septober_payload(todo: ObsidianTodo) -> dict:
    """Convert a classified ObsidianTodo to a Septober API create payload."""
    # Store obpbt hash in sys_notes for dedup (belt & suspenders with source_ref)
    sys_notes = f"obpbt_hash:{todo.hash_id}" if todo.hash_id else None
    if todo.verdict_reason:
        sys_notes = f"{sys_notes}\n{todo.verdict_reason}" if sys_notes else todo.verdict_reason

    return {
        "title": todo.title,
        "category": todo.septober_category,
        "priority": todo.septober_priority,
        "is_wish": todo.septober_is_wish or todo.verdict == Verdict.REFERENCE,
        "source": "obsidian",
        "source_ref": f"{todo.source_file}:{todo.source_line}",
        "url": todo.septober_url,
        "due": todo.date.isoformat() if todo.date and todo.date >= date.today() else None,
        "tags": todo.tags[:5],
        "sys_notes": sys_notes,
    }

