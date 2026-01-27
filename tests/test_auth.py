"""Authentication endpoint tests."""

import os


def test_signup_creates_user(client, test_db):
    """POST /auth/signup should create new user and return user data."""

    response = client.post(
        "/auth/signup",
        json={
            "email": "newuser@example.com",
            "username": "newuser",
            "password": "securepassword123",
        },
    )

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "newuser@example.com"
    assert data["username"] == "newuser"
    assert "password" not in data  # Password should never be returned


def test_signup_duplicate_email_rejected(client, test_user, test_db):
    """POST /auth/signup with existing email should return 409."""

    response = client.post(
        "/auth/signup",
        json={
            "email": test_user.email,  # Created through test_user fixture
            "username": "differentuser",
            "password": "password123",
        },
    )

    # 409 Conflict = "resource already exists" (vs 400 = "bad input format")
    assert response.status_code == 409


def test_login_returns_token(client, test_user):
    """POST /auth/login with valid credentials should return JWT token."""

    response = client.post(
        "/auth/login",
        json={
            "email": test_user.email,
            "password": "password123",  # Password set in test_user fixture
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_wrong_password_rejected(client, test_user):
    """POST /auth/login with wrong password should return 401."""

    response = client.post(
        "/auth/login",
        json={"email": test_user.email, "password": "wrongpassword"},
    )

    assert response.status_code == 401


def test_protected_endpoint_requires_auth(client):
    """GET /me without auth headers should return 403 (HTTPBearer default)."""

    response = client.get("/me")

    # Auth dependency runs BEFORE Pydantic validation.
    # HTTPBearer returns 403 Forbidden when no credentials provided
    assert response.status_code == 403


def test_signup_duplicate_username_rejected(client, test_user, test_db):
    """POST /auth/signup with existing username should return 409."""
    response = client.post(
        "/auth/signup",
        json={
            "email": "different@example.com",
            "username": test_user.username,
            "password": "password123",
        },
    )

    assert response.status_code == 409


def test_signup_admin_success(client, test_db):
    """POST /auth/signup-admin with correct secret creates admin user."""
    admin_secret = os.getenv("ADMIN_SECRET")

    response = client.post(
        "/auth/signup-admin",
        json={
            "email": "newadmin@example.com",
            "username": "newadmin",
            "password": "adminpass123",
            "admin_secret": admin_secret,
        },
    )

    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "newadmin@example.com"
    assert data["role"] == "admin"


def test_signup_admin_wrong_secret_rejected(client, test_db):
    """POST /auth/signup-admin with wrong secret should return 403."""
    response = client.post(
        "/auth/signup-admin",
        json={
            "email": "badactor@example.com",
            "username": "badactor",
            "password": "password123",
            "admin_secret": "wrong-secret-value",
        },
    )

    assert response.status_code == 403


def test_signup_invalid_email_rejected(client, test_db):
    """POST /auth/signup with invalid email format should return 422."""
    response = client.post(
        "/auth/signup",
        json={
            "email": "not-an-email",
            "username": "testuser",
            "password": "password123",
        },
    )

    # Pydantic validation returns 422 Unprocessable Entity
    assert response.status_code == 422


def test_signup_short_password_rejected(client, test_db):
    """POST /auth/signup with password < 6 chars should return 422."""
    response = client.post(
        "/auth/signup",
        json={
            "email": "valid@example.com",
            "username": "testuser",
            "password": "short",
        },
    )

    # Pydantic validation returns 422 Unprocessable Entity
    assert response.status_code == 422


def test_login_nonexistent_email_rejected(client, test_db):
    """POST /auth/login with non-existent email should return 401."""
    response = client.post(
        "/auth/login",
        json={
            "email": "nobody@example.com",
            "password": "password123",
        },
    )

    assert response.status_code == 401
