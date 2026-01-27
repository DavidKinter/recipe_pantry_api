"""Database inspection endpoint tests."""


def test_get_tables_returns_list(client, auth_headers, test_db):
    """GET /db/tables should return list of table names."""
    response = client.get("/db/tables", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert "tables" in data
    assert isinstance(data["tables"], list)
    # Should include our known tables
    assert "users" in data["tables"]
    assert "recipes" in data["tables"]


def test_admin_get_table_data(client, admin_headers, test_db):
    """GET /db/tables/{name} should return table data for admin."""
    response = client.get("/db/tables/users", headers=admin_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["table_name"] == "users"
    assert "columns" in data
    assert "rows" in data


def test_get_table_data_requires_admin(client, auth_headers, test_db):
    """Non-admin users cannot access table data."""
    response = client.get("/db/tables/users", headers=auth_headers)

    assert response.status_code == 403


def test_get_table_invalid_name_returns_404(client, admin_headers, test_db):
    """Requesting a nonexistent table returns 404."""
    response = client.get(
        "/db/tables/nonexistent_table", headers=admin_headers
    )

    assert response.status_code == 404
