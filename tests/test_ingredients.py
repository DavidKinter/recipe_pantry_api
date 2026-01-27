"""Ingredient reference endpoint tests."""


def test_get_ingredients_returns_list(client, auth_headers, test_db):
    """GET /ingredients should return list of available ingredients."""
    response = client.get("/ingredients", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    # Check structure of first item
    assert "id" in data[0]
    assert "name" in data[0]
