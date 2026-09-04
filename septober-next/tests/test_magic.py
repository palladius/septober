"""Tests for the magic regex parser — ported from Ruby's Todo#apply_todo_regex_magic."""
import pytest
from datetime import date, timedelta
from septober.magic import apply_magic, extract_tags


class TestExtractTags:
    """Test @tag extraction from text."""
    
    def test_single_tag(self):
        text, tags = extract_tags("buy milk @shopping")
        assert text == "buy milk"
        assert tags == ["shopping"]
    
    def test_multiple_tags(self):
        text, tags = extract_tags("parse this @a @bbbb difficult string @ccc")
        assert text == "parse this difficult string"
        assert set(tags) == {"a", "bbbb", "ccc"}
    
    def test_no_tags(self):
        text, tags = extract_tags("buy milk")
        assert text == "buy milk"
        assert tags == []
    
    def test_only_tags(self):
        text, tags = extract_tags("@health @urgent")
        assert text.strip() == ""
        assert set(tags) == {"health", "urgent"}


class TestApplyMagic:
    """Test the full magic parser."""
    
    def test_today_keyword(self):
        result = apply_magic("buy milk today")
        assert result.due == date.today()
        
    def test_oggi_keyword(self):
        result = apply_magic("comprare latte oggi")
        assert result.due == date.today()
    
    def test_tomorrow_keyword(self):
        result = apply_magic("meeting tomorrow")
        assert result.due == date.today() + timedelta(days=1)
    
    def test_domani_keyword(self):
        result = apply_magic("riunione domani")
        assert result.due == date.today() + timedelta(days=1)
    
    def test_yesterday_keyword(self):
        result = apply_magic("was due yesterday")
        assert result.due == date.today() - timedelta(days=1)
    
    def test_default_due_one_week(self):
        result = apply_magic("generic task")
        assert result.due == date.today() + timedelta(days=7)
    
    def test_high_priority_plus(self):
        result = apply_magic("+important task")
        assert result.priority == 4
    
    def test_highest_priority_double_plus(self):
        result = apply_magic("++critical task")
        assert result.priority == 5
    
    def test_low_priority_minus(self):
        result = apply_magic("-low priority")
        assert result.priority == 2
    
    def test_lowest_priority_double_minus(self):
        result = apply_magic("--very low")
        assert result.priority == 1
    
    def test_exclamation_priority(self):
        result = apply_magic("urgent task!")
        assert result.priority == 4
    
    def test_double_exclamation_priority(self):
        result = apply_magic("super urgent!!")
        assert result.priority == 5
    
    def test_url_extraction(self):
        result = apply_magic("check this https://example.com/page article")
        assert result.url == "https://example.com/page"
        assert "https://example.com/page" not in result.title
    
    def test_tag_extraction(self):
        result = apply_magic("buy shoes @shopping @personal")
        assert "shopping" in result.tags
        assert "personal" in result.tags
        assert "@shopping" not in result.title
        assert "@personal" not in result.title
    
    def test_combined_magic(self):
        result = apply_magic("+buy shoes tomorrow @shopping https://nike.com")
        assert result.priority == 4
        assert result.due == date.today() + timedelta(days=1)
        assert "shopping" in result.tags
        assert result.url == "https://nike.com"
        assert "buy shoes" in result.title.lower()
    
    def test_category_prefix(self):
        result = apply_magic("lavoro: prepare presentation")
        assert result.category == "lavoro"
        assert "prepare presentation" in result.title
    
    def test_wish_flag(self):
        result = apply_magic("learn piano #wish")
        assert result.is_wish is True
        assert "#wish" not in result.title
    
    def test_sogno_flag(self):
        result = apply_magic("visitare il Giappone #sogno")
        assert result.is_wish is True
