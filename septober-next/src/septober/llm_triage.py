"""LLM-powered triage for borderline Obsidian todos using Gemini.

Only called for items the regex filter can't confidently classify.
Batches all borderline items into a single LLM call for efficiency.
"""

import json
import sys
from typing import Optional

from septober.obsidian import ObsidianTodo, Verdict


LLM_TRIAGE_PROMPT = """You are a personal task classifier for an Italian software engineer living in Switzerland.
You will receive a list of TODO items extracted from an Obsidian vault.

For each item, decide:
1. **verdict**: Is this a real actionable task? Options: `actionable`, `noise`, `stale`, `reference`
2. **category**: One of: `famiglia` (family), `personale` (personal/health/hobbies), `lavoro` (work/conferences), `finanze` (banks/taxes/house), `shopping` (shopping/wishlist)
3. **priority**: 1 (lowest) to 5 (highest)
4. **clean_title**: Rewrite the title to be clear and actionable. Remove emoji prefixes, fix grammar, make it concise.
5. **reasoning**: One-line explanation of your classification.

Context:
- The user is a Google Developer Advocate who travels frequently for conferences
- Items about "DevFest", "WAD", "Summit", "GCP" = lavoro
- Items about family trips, "Lido", "famiglia" = famiglia  
- Items about banks, taxes, house = finanze
- Bare "TODO" fragments with no clear action = noise
- Links/videos without action = reference (save as wish)

Respond with a JSON array. Each element:
{"index": 0, "verdict": "actionable", "category": "lavoro", "priority": 4, "clean_title": "Prepare slides for Berlin WAD keynote", "reasoning": "Clear work task with conference context"}

Items to classify:
"""


def _build_items_text(items: list[ObsidianTodo]) -> str:
    """Build the items list for the LLM prompt."""
    parts = []
    for i, item in enumerate(items):
        parts.append(
            f"[{i}] Title: {item.title}\n"
            f"    Source: {item.source_file}:{item.source_line}\n"
            f"    Date: {item.date}\n"
            f"    Tags: {', '.join(item.tags) if item.tags else 'none'}\n"
            f"    Starred: {item.starred}\n"
            f"    Context emojis: {' '.join(item.context_emojis) if item.context_emojis else 'none'}"
        )
    return "\n\n".join(parts)


def triage_borderline_items(
    items: list[ObsidianTodo],
    api_key: str,
    model_name: str = "gemini-2.0-flash",
) -> list[ObsidianTodo]:
    """Send borderline items to Gemini for classification.
    
    Returns the same items with updated verdict, category, priority, and title.
    """
    if not items:
        return items
    
    if not api_key:
        print("❌ SEPTOBER_GEMINI_API_KEY is not set!", file=sys.stderr)
        print("   Set it in your .env file or environment:", file=sys.stderr)
        print("   export SEPTOBER_GEMINI_API_KEY='your-key-here'", file=sys.stderr)
        sys.exit(1)
    
    try:
        from google import genai
    except ImportError:
        print("❌ google-genai not installed. Run: uv sync", file=sys.stderr)
        sys.exit(1)
    
    client = genai.Client(api_key=api_key)
    
    prompt = LLM_TRIAGE_PROMPT + _build_items_text(items)
    
    try:
        response = client.models.generate_content(
            model=model_name,
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.1,  # Low temp for consistent classification
            ),
        )
        
        results = json.loads(response.text)
        
        for result in results:
            idx = result.get("index", -1)
            if 0 <= idx < len(items):
                item = items[idx]
                verdict_str = result.get("verdict", "noise")
                if verdict_str in [v.value for v in Verdict]:
                    item.verdict = Verdict(verdict_str)
                else:
                    item.verdict = Verdict.NOISE
                
                category = result.get("category", "personale")
                if category in ("famiglia", "personale", "lavoro", "finanze", "shopping"):
                    item.septober_category = category
                
                priority = result.get("priority", 3)
                if isinstance(priority, int) and 1 <= priority <= 5:
                    item.septober_priority = priority
                
                clean_title = result.get("clean_title", "")
                if clean_title:
                    item.title = clean_title
                
                reasoning = result.get("reasoning", "")
                item.verdict_reason = f"🤖 LLM: {reasoning}"
    
    except Exception as e:
        print(f"⚠️  LLM triage failed: {e}", file=sys.stderr)
        print("   Falling back: marking all borderline items as actionable", file=sys.stderr)
        for item in items:
            item.verdict = Verdict.ACTIONABLE
            item.verdict_reason = "LLM triage failed — keeping as actionable"
    
    return items
