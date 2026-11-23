"""Tests for the Todos API."""
import pytest
from fastapi.testclient import TestClient


class TestTodosCRUD:
    """Test basic CRUD operations."""
    
    def test_create_todo(self, client: TestClient):
        response = client.post("/api/todos", json={
            "title": "Buy milk tomorrow @shopping",
            "category": "personale",
        })
        assert response.status_code == 201
        data = response.json()
        assert "buy milk" in data["title"].lower()
        assert data["status"] == "active"
        assert data["category"] == "personale"
    
    def test_list_todos_empty(self, client: TestClient):
        response = client.get("/api/todos")
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 0
        assert data["items"] == []
    
    def test_list_todos_with_items(self, client: TestClient):
        # Create two todos
        client.post("/api/todos", json={"title": "Task 1"})
        client.post("/api/todos", json={"title": "Task 2"})
        response = client.get("/api/todos")
        data = response.json()
        assert data["total"] == 2
    
    def test_get_todo(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Test task"})
        todo_id = create.json()["id"]
        response = client.get(f"/api/todos/{todo_id}")
        assert response.status_code == 200
        assert response.json()["id"] == todo_id
    
    def test_get_todo_not_found(self, client: TestClient):
        response = client.get("/api/todos/999")
        assert response.status_code == 404
    
    def test_update_todo(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Old title"})
        todo_id = create.json()["id"]
        response = client.patch(f"/api/todos/{todo_id}", json={"title": "New title"})
        assert response.status_code == 200
        assert response.json()["title"] == "New title"
    
    def test_delete_todo(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "To delete"})
        todo_id = create.json()["id"]
        response = client.delete(f"/api/todos/{todo_id}")
        assert response.status_code == 204
        # Verify it's gone
        response = client.get(f"/api/todos/{todo_id}")
        assert response.status_code == 404


class TestTodoActions:
    """Test quick actions."""
    
    def test_mark_done(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Do this"})
        todo_id = create.json()["id"]
        response = client.post(f"/api/todos/{todo_id}/done")
        assert response.status_code == 200
        assert response.json()["status"] == "done"
        assert response.json()["completed_at"] is not None
    
    def test_mark_undone(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Reactivate me"})
        todo_id = create.json()["id"]
        client.post(f"/api/todos/{todo_id}/done")
        response = client.post(f"/api/todos/{todo_id}/undone")
        assert response.status_code == 200
        assert response.json()["status"] == "active"
        assert response.json()["completed_at"] is None
    
    def test_toggle(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Toggle me"})
        todo_id = create.json()["id"]
        # Toggle to done
        r1 = client.post(f"/api/todos/{todo_id}/toggle")
        assert r1.json()["status"] == "done"
        # Toggle back to active
        r2 = client.post(f"/api/todos/{todo_id}/toggle")
        assert r2.json()["status"] == "active"
    
    def test_procrastinate(self, client: TestClient):
        create = client.post("/api/todos", json={"title": "Do later"})
        todo_id = create.json()["id"]
        response = client.post(f"/api/todos/{todo_id}/procrastinate")
        assert response.status_code == 200
        # Due should be pushed forward


class TestTodoFilters:
    """Test filtering."""
    
    def test_filter_by_category(self, client: TestClient):
        client.post("/api/todos", json={"title": "Work task", "category": "lavoro"})
        client.post("/api/todos", json={"title": "Home task", "category": "famiglia"})
        response = client.get("/api/todos?category=lavoro")
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["category"] == "lavoro"
    
    def test_filter_by_wish(self, client: TestClient):
        client.post("/api/todos", json={"title": "Real task", "is_wish": False})
        client.post("/api/todos", json={"title": "Dream task", "is_wish": True})
        response = client.get("/api/todos?is_wish=true")
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["is_wish"] is True


class TestHealthEndpoints:
    """Test health/status endpoints."""
    
    def test_healthz(self, client: TestClient):
        response = client.get("/healthz")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"
    
    def test_statusz(self, client: TestClient):
        response = client.get("/statusz")
        assert response.status_code == 200
        assert "version" in response.json()
