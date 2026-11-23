"""Tests for obsidian.py parsing and classification."""
import pytest
from datetime import date, timedelta
from septober.obsidian import (
    parse_obpbt_line, classify_todo, Verdict, ObsidianTodo,
    parse_and_classify,
)


class TestParseObpbtLine:
    """Test parsing of obpbt output lines."""

    def test_parse_basic_open_todo(self):
        line = "2026-08-18     [ ]  #5480748  Installare app TV7  (TODOs/TODOz.md:4)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.date == date(2026, 8, 18)
        assert todo.status == "open"
        assert todo.hash_id == "5480748"
        assert todo.source_file == "TODOs/TODOz.md"
        assert todo.source_line == 4
        assert "Installare" in todo.title

    def test_parse_starred_item(self):
        line = "2026-08-20  ⭐ [ ]  #e9a218d  Important task  (TODOz.md:4)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.starred is True

    def test_parse_done_item(self):
        line = "2026-07-08     [x]  #9a5afa2  Book Concur  (Viaggio.md:29)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.status == "done"

    def test_parse_idea_item(self):
        line = "2026-07-12     💡  #9de5edc  TODO  (file.md:23)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.status == "idea"

    def test_parse_with_priority_emoji(self):
        line = "2026-07-12  🔴 [ ]  #ee9abef  Urgent task  (file.md:22)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.septober_priority == 5

    def test_parse_with_tags(self):
        line = "2026-08-18     [ ]  #5480748  Task #casa #tech  (file.md:4)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert "casa" in todo.tags
        assert "tech" in todo.tags

    def test_parse_strips_ansi_codes(self):
        line = "\x1b[36m2026-08-18\x1b[39m     [ ]  #5480748  Task  (file.md:4)"
        todo = parse_obpbt_line(line)
        assert todo is not None
        assert todo.date == date(2026, 8, 18)

    def test_parse_non_todo_line(self):
        line = "Some random text"
        assert parse_obpbt_line(line) is None

    def test_parse_empty_line(self):
        assert parse_obpbt_line("") is None


class TestClassifyTodo:
    """Test the classification logic."""

    def _make_todo(self, title="Test task", status="open", date_val=None,
                   starred=False, source_file="file.md", tags=None,
                   hash_id="abc1234", priority_emoji=""):
        return ObsidianTodo(
            raw_line=f"2026-08-20  [ ]  #{hash_id}  {title}  ({source_file}:1)",
            title=title,
            status=status,
            date=date_val or date.today(),
            starred=starred,
            source_file=source_file,
            source_line=1,
            tags=tags or [],
            hash_id=hash_id,
            priority_emoji=priority_emoji,
        )

    def test_done_items_classified_as_done(self):
        todo = self._make_todo(status="done")
        result = classify_todo(todo)
        assert result.verdict == Verdict.DONE

    def test_bare_todo_is_noise(self):
        todo = self._make_todo(title="TODO")
        result = classify_todo(todo)
        assert result.verdict == Verdict.NOISE

    def test_short_title_is_noise(self):
        todo = self._make_todo(title="hi")
        result = classify_todo(todo)
        assert result.verdict == Verdict.NOISE

    def test_action_verb_is_actionable(self):
        todo = self._make_todo(title="Installare app sulla TV")
        result = classify_todo(todo)
        assert result.verdict == Verdict.ACTIONABLE

    def test_starred_is_actionable(self):
        todo = self._make_todo(title="Something important", starred=True)
        result = classify_todo(todo)
        assert result.verdict == Verdict.ACTIONABLE
        assert result.septober_priority >= 4

    def test_stale_travel_item(self):
        old_date = date.today() - timedelta(days=30)
        todo = self._make_todo(
            title="Prenotare hotel",
            date_val=old_date,
            source_file="20260101 Viaggio Test.md"
        )
        result = classify_todo(todo)
        assert result.verdict == Verdict.STALE

    def test_future_travel_is_actionable(self):
        future_date = date.today() + timedelta(days=30)
        todo = self._make_todo(
            title="Prenotare volo per Napoli",
            date_val=future_date
        )
        result = classify_todo(todo)
        assert result.verdict == Verdict.ACTIONABLE

    def test_borderline_todo_with_text(self):
        """A TODO-prefixed item with substantial text but no action verb → BORDERLINE."""
        todo = self._make_todo(title="TODO sembra il piu scambiato di tutto il mondo")
        result = classify_todo(todo)
        assert result.verdict == Verdict.BORDERLINE

    def test_borderline_no_action_no_priority(self):
        """Item with substantial text but no action verb, no priority, not starred → BORDERLINE."""
        todo = self._make_todo(title="Something about the conference next month in Berlin")
        result = classify_todo(todo)
        assert result.verdict == Verdict.BORDERLINE

    def test_category_from_tag(self):
        todo = self._make_todo(title="Installare qualcosa", tags=["casa", "tech"])
        result = classify_todo(todo)
        assert result.septober_category in ("finanze", "personale")  # casa→finanze or tech→personale

    def test_category_from_travel_source(self):
        todo = self._make_todo(
            title="Preparare slides",
            source_file="20260708 Viaggio Berlino WAD.md"
        )
        result = classify_todo(todo)
        assert result.septober_category == "lavoro"


class TestLLMTriageModule:
    """Test the LLM triage module (with mocked responses)."""

    def test_missing_api_key_exits(self):
        from septober.llm_triage import triage_borderline_items
        from septober.obsidian import ObsidianTodo, Verdict
        item = ObsidianTodo(raw_line="test", title="Test", verdict=Verdict.BORDERLINE)
        with pytest.raises(SystemExit):
            triage_borderline_items([item], api_key="")

    def test_empty_list_returns_empty(self):
        from septober.llm_triage import triage_borderline_items
        result = triage_borderline_items([], api_key="fake-key")
        assert result == []

    def test_build_items_text(self):
        from septober.llm_triage import _build_items_text
        from septober.obsidian import ObsidianTodo
        from datetime import date
        item = ObsidianTodo(
            raw_line="test",
            title="Test task",
            source_file="file.md",
            source_line=10,
            date=date(2026, 8, 23),
            tags=["casa"],
        )
        text = _build_items_text([item])
        assert "[0]" in text
        assert "Test task" in text
        assert "file.md" in text
        assert "casa" in text
