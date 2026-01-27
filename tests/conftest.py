"""
Shared pytest fixtures for Recipe Pantry API tests.

Provides test database setup, FastAPI TestClient, and authentication
fixtures for integration testing against PostgreSQL.
"""

import os

from dotenv import load_dotenv
from fastapi.testclient import TestClient
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Loads env vars BEFORE importing app (app validates at import time)
load_dotenv()

from src.auth import create_access_token
from src.auth_utils import hash_password
from src.database import Base, get_db
from src.main import app
from src.models import Ingredient, User

# Uses empty PostgreSQL database for testing
SQLALCHEMY_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    "postgresql://recipe_user:recipe_pass@localhost:5432/recipe_pantry_api_test",
)

engine = create_engine(SQLALCHEMY_DATABASE_URL)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# scope="function" = fresh tables for EACH test (critical for isolation!)
# Uses the "drop_all/create_all" pattern: Base.metadata handles table lifecycle.
@pytest.fixture(scope="function")
def test_db():
    """Creates fresh tables for each test (database itself persists)."""
    # Creates all tables
    Base.metadata.create_all(bind=engine)

    db = TestingSessionLocal()

    # Seed test ingredients - REQUIRED because:
    # 1. Recipe creation validates ingredients exist in database
    # 2. Recipes need >=1 ingredient (CHECK constraint)
    # 3. Matching algorithm needs ingredients to calculate percentages
    test_ingredients = [
        Ingredient(name="eggs"),
        Ingredient(name="milk"),
        Ingredient(name="flour"),
        Ingredient(name="sugar"),
        Ingredient(name="butter"),
        Ingredient(name="pasta"),
        Ingredient(name="garlic"),
    ]
    db.add_all(test_ingredients)
    db.commit()

    yield db

    # Cleanup after test
    db.close()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(test_db):
    """Creates a test client with database override."""

    # Overrides FastAPI's Depends(get_db) for DEV database for proper testing
    def override_get_db():
        try:
            yield test_db
        finally:
            pass

    # Registers the override: get_db() now returns test_db
    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    # Clean up: remove override so other tests start fresh
    app.dependency_overrides.clear()


@pytest.fixture
def test_user(test_db):
    """Creates a test user."""
    user = User(
        email="test@example.com",
        username="testuser",
        password_hash=hash_password("password123"),
        role="user",
    )
    test_db.add(user)
    test_db.commit()
    test_db.refresh(
        user
    )  # Reloads from DB to get auto-generated fields (id, defaults)

    return user


@pytest.fixture
def auth_headers(test_user):
    """
    Creates authorization headers with JWT token.

    Using this fixture implicitly creates a test_user.
    The token authenticates as: test@example.com / password123
    """
    token = create_access_token(
        data={"sub": str(test_user.id), "email": test_user.email}
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def second_user(test_db):
    """Creates a second test user for multi-user scenarios."""
    user = User(
        email="other@example.com",
        username="otheruser",
        password_hash=hash_password("password456"),
        role="user",
    )
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    return user


@pytest.fixture
def second_auth_headers(second_user):
    """Creates authorization headers for the second user."""
    token = create_access_token(
        data={"sub": str(second_user.id), "email": second_user.email}
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def admin_user(test_db):
    """Creates an admin user for admin endpoint tests."""
    user = User(
        email="admin@example.com",
        username="adminuser",
        password_hash=hash_password("adminpass123"),
        role="admin",
    )
    test_db.add(user)
    test_db.commit()
    test_db.refresh(user)
    return user


@pytest.fixture
def admin_headers(admin_user):
    """Creates authorization headers for the admin user."""
    token = create_access_token(
        data={"sub": str(admin_user.id), "email": admin_user.email}
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def test_recipe(client, auth_headers):
    """Creates a simple public recipe for matching tests."""
    response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Simple Eggs",
            "ingredients_json": ["eggs"],
            "instructions": "Cook eggs",
            "prep_minutes": 5,
            "is_public": True,
        },
    )
    return response.json()
