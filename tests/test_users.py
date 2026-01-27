"""User profile endpoint tests."""


def test_get_current_user(client, auth_headers, test_user):
    """GET /me should return current user's profile."""
    response = client.get("/me", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user.email
    assert data["username"] == test_user.username


def test_update_user_profile(client, auth_headers, test_db):
    """PUT /me should update user's profile."""
    response = client.put(
        "/me", headers=auth_headers, json={"username": "updatedname"}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "updatedname"


def test_delete_account(client, test_db):
    """DELETE /me should delete user's account."""
    # Creates a fresh user for this test
    client.post(
        "/auth/signup",
        json={
            "email": "todelete@example.com",
            "username": "todelete",
            "password": "password123",
        },
    )

    # Login to get token
    login_response = client.post(
        "/auth/login",
        json={
            "email": "todelete@example.com",
            "password": "password123",
        },
    )
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Deletes the account
    delete_response = client.delete("/me", headers=headers)

    assert delete_response.status_code == 200
    assert "deleted" in delete_response.json()["message"]


def test_delete_account_admin_blocked(client, admin_headers, test_db):
    """DELETE /me should return 400 for admin users (safety feature)."""
    response = client.delete("/me", headers=admin_headers)

    # Safety pattern: prevents admins from accidentally locking themselves out
    assert response.status_code == 400
    assert "admin" in response.json()["detail"].lower()


def test_admin_update_user(client, admin_headers, test_user, test_db):
    """PUT /users/{id} should update user for admin."""
    response = client.put(
        f"/users/{test_user.id}",
        headers=admin_headers,
        json={"username": "admin_updated_name"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "admin_updated_name"


def test_admin_delete_user(client, admin_headers, test_db):
    """DELETE /users/{id} should delete non-admin user for admin."""
    # Creates a user to delete
    client.post(
        "/auth/signup",
        json={
            "email": "tobedeleted@example.com",
            "username": "tobedeleted",
            "password": "password123",
        },
    )

    # Gets all users to find the new user's ID
    # Uses the login to get the user ID indirectly
    login_response = client.post(
        "/auth/login",
        json={
            "email": "tobedeleted@example.com",
            "password": "password123",
        },
    )
    token = login_response.json()["access_token"]
    me_response = client.get(
        "/me", headers={"Authorization": f"Bearer {token}"}
    )
    user_id = me_response.json()["id"]

    # Admin deletes the user
    response = client.delete(f"/users/{user_id}", headers=admin_headers)

    assert response.status_code == 200
    assert "deleted" in response.json()["message"]


def test_admin_get_user_by_id(client, admin_headers, test_user, test_db):
    """GET /users/{id} should return user for admin."""
    response = client.get(f"/users/{test_user.id}", headers=admin_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user.email


def test_get_user_by_id_non_admin_rejected(client, auth_headers, test_db):
    """GET /users/{id} should return 403 for non-admin users."""
    response = client.get("/users/1", headers=auth_headers)

    # 403 Forbidden = "I know who you are, but you can't do this"
    # (vs 401 Unauthorized = "I don't know who you are")
    assert response.status_code == 403


def test_admin_update_user_not_found(client, admin_headers, test_db):
    """PUT /users/{id} should return 404 for non-existent user."""
    response = client.put(
        "/users/99999",
        headers=admin_headers,
        json={"username": "wont_work"},
    )

    assert response.status_code == 404


def test_admin_delete_user_not_found(client, admin_headers, test_db):
    """DELETE /users/{id} should return 404 for non-existent user."""
    response = client.delete("/users/99999", headers=admin_headers)

    assert response.status_code == 404
