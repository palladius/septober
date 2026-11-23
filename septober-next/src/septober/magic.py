import re
from dataclasses import dataclass
from datetime import date, timedelta
from typing import Tuple, List, Optional
import datetime

@dataclass
class MagicResult:
    """Result of applying magic regex parsing to a todo title."""
    title: str
    due: Optional[date]
    priority: Optional[int]
    url: Optional[str]
    tags: List[str]
    logs: List[str]
    category: Optional[str] = None
    is_wish: bool = False

def extract_tags(text: str) -> Tuple[str, List[str]]:
    """Extract @tags from text, return (cleaned_text, tag_list)."""
    words = text.split()
    tags = []
    depured_words = []
    for w in words:
        if w.startswith('@') and len(w) > 1:
            tags.append(w[1:])
        else:
            depured_words.append(w)
    return ' '.join(depured_words), tags

def apply_magic(raw_title: str) -> MagicResult:
    logs = []
    title = raw_title
    due = None
    priority = None
    url = None
    category = None
    is_wish = False
    
    # Priority
    if re.search(r'^\+\+|!!', title):
        priority = 5
    elif re.search(r'^\+|!', title):
        priority = 4
    elif re.search(r'^--|\.\.\.', title):
        priority = 1
    elif re.search(r'^-|\.\.', title):
        priority = 2

    # Date
    today = date.today()
    if re.search(r'\b(today|oggi)\b', title, re.IGNORECASE):
        due = today
    elif re.search(r'\b(tomorrow|domani)\b', title, re.IGNORECASE):
        due = today + timedelta(days=1)
    elif re.search(r'\b(yesterday|ieri)\b', title, re.IGNORECASE):
        due = today - timedelta(days=1)
    elif re.search(r'\b(la prossima settimana|next week)\b', title, re.IGNORECASE):
        due = today + timedelta(days=7)
    
    match_in_days = re.search(r'\b(?:fra|in)\s+(\d+)\s+(?:giorni|days)\b', title, re.IGNORECASE)
    if match_in_days:
        due = today + timedelta(days=int(match_in_days.group(1)))
        
    match_by_date = re.search(r'\bby\s+([\d\-]+)\b', title, re.IGNORECASE)
    if match_by_date:
        try:
            due = datetime.date.fromisoformat(match_by_date.group(1))
        except ValueError:
            logs.append(f"Could not parse date {match_by_date.group(1)}")
            
    if due is None:
        due = today + timedelta(days=7)
        
    # URL
    url_match = re.search(r' (https?://\S+)($|\s)', title)
    if url_match:
        url = url_match.group(1)
        title = title.replace(url, ' (URL) ')

    # Wish
    if '#wish' in title or '#sogno' in title:
        is_wish = True
        title = title.replace('#wish', '').replace('#sogno', '')

    # Category
    cat_match = re.match(r'^([\w\s]+):', title)
    if cat_match:
        category = cat_match.group(1).strip()
        title = title[len(cat_match.group(0)):].strip()

    title, tags = extract_tags(title)
    
    return MagicResult(
        title=title.strip(),
        due=due,
        priority=priority,
        url=url,
        tags=tags,
        logs=logs,
        category=category,
        is_wish=is_wish
    )
