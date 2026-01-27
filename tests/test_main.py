"""Main application endpoint tests."""


def test_root_endpoint(client):
    """GET / should return API info."""
    response = client.get("/")

    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Recipe Pantry API"
    assert "version" in data


def test_health_check(client):
    """GET /health should return healthy status."""
    response = client.get("/health")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["database"] == "connected"
