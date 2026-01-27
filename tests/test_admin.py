"""Admin endpoint tests."""


def test_admin_get_users(client, admin_headers, test_user, test_db):
    """GET /users should return list of users for admin."""
    response = client.get("/users", headers=admin_headers)

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


def test_admin_get_users_requires_admin(client, auth_headers, test_db):
    """GET /users should return 403 for non-admin users."""
    response = client.get("/users", headers=auth_headers)

    assert response.status_code == 403


def test_admin_get_user_by_id(client, admin_headers, test_user, test_db):
    """GET /users/{id} should return specific user for admin."""
    response = client.get(f"/users/{test_user.id}", headers=admin_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_user.id
    assert data["email"] == test_user.email


def test_admin_get_user_not_found(client, admin_headers, test_db):
    """GET /users/{id} should return 404 for non-existent user."""
    response = client.get("/users/99999", headers=admin_headers)

    assert response.status_code == 404


def test_admin_delete_user(client, admin_headers, test_db):
    """DELETE /users/{id} should delete regular user."""
    # Create a user to delete
    signup_response = client.post(
        "/auth/signup",
        json={
            "email": "victim@example.com",
            "username": "victim",
            "password": "password123",
        },
    )
    user_id = signup_response.json()["id"]

    # Admin deletes the user
    delete_response = client.delete(
        f"/users/{user_id}",
        headers=admin_headers,
    )

    assert delete_response.status_code == 200
    assert "deleted" in delete_response.json()["message"]


def test_admin_delete_admin_blocked(
    client,
    admin_headers,
    second_user,
    test_db,
):
    """DELETE /users/{id} should return 400 when trying to delete admin."""
    # Grants second user admin rights
    second_user.role = "admin"
    test_db.commit()

    response = client.delete(
        f"/users/{second_user.id}",
        headers=admin_headers,
    )

    assert response.status_code == 400


def test_admin_get_all_recipes(client, admin_headers, auth_headers, test_db):
    """GET /recipes should return all recipes for admin."""
    # Create a recipe first
    client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Admin Test Recipe",
            "ingredients_json": ["eggs"],
            "instructions": "Test",
            "prep_minutes": 5,
            "is_public": False,
        },
    )

    response = client.get("/recipes", headers=admin_headers)

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_admin_get_recipes_requires_admin(client, auth_headers, test_db):
    """GET /recipes should return 403 for non-admin users."""
    response = client.get("/recipes", headers=auth_headers)

    assert response.status_code == 403
