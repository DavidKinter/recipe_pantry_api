"""Pantry management endpoint tests."""

from src.models import Ingredient


def test_add_ingredient_to_pantry(client, auth_headers, test_db):
    """POST /me/pantry/ingredients adds ingredient by ID."""
    eggs = test_db.query(Ingredient).filter_by(name="eggs").first()
    response = client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": eggs.id},
    )

    assert response.status_code == 201
    data = response.json()
    assert data["ingredient_id"] == eggs.id
    assert data["ingredient_name"] == "eggs"


def test_get_pantry_contents(client, auth_headers, test_db):
    """GET /me/pantry returns pantry contents."""
    milk = test_db.query(Ingredient).filter_by(name="milk").first()
    client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": milk.id},
    )

    response = client.get("/me/pantry", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert any(
        item["ingredient_name"] == "milk" for item in data["ingredients"]
    )


def test_remove_ingredient_from_pantry(client, auth_headers, test_db):
    """DELETE /me/pantry/ingredients/{id} removes ingredient."""
    flour = test_db.query(Ingredient).filter_by(name="flour").first()
    add_response = client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": flour.id},
    )
    ingredient_id = add_response.json()["ingredient_id"]

    delete_response = client.delete(
        f"/me/pantry/ingredients/{ingredient_id}", headers=auth_headers
    )

    assert delete_response.status_code == 200
    assert "removed" in delete_response.json()["message"]


def test_replace_pantry(client, auth_headers, test_db):
    """PUT /me/pantry replaces entire pantry with new ingredients."""
    # Get ingredient IDs for the replacement
    eggs = test_db.query(Ingredient).filter_by(name="eggs").first()
    milk = test_db.query(Ingredient).filter_by(name="milk").first()

    # Add an initial ingredient (will be replaced)
    flour = test_db.query(Ingredient).filter_by(name="flour").first()
    client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": flour.id},
    )

    # Replace entire pantry with eggs and milk
    response = client.put(
        "/me/pantry",
        headers=auth_headers,
        json={"ingredient_ids": [eggs.id, milk.id]},
    )

    assert response.status_code == 200
    data = response.json()
    names = [item["ingredient_name"] for item in data["ingredients"]]
    assert "eggs" in names
    assert "milk" in names
    # Flour should be gone (replaced, not merged)
    assert "flour" not in names


def test_replace_pantry_invalid_id_rejected(client, auth_headers, test_db):
    """PUT /me/pantry with invalid ingredient ID should return 400."""
    eggs = test_db.query(Ingredient).filter_by(name="eggs").first()

    response = client.put(
        "/me/pantry",
        headers=auth_headers,
        json={"ingredient_ids": [eggs.id, 99999]},  # 99999 doesn't exist
    )

    assert response.status_code == 400


def test_add_invalid_ingredient_rejected(client, auth_headers, test_db):
    """POST /me/pantry/ingredients with invalid ID should return 404."""
    response = client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": 99999},
    )

    assert response.status_code == 404


def test_remove_nonexistent_ingredient_rejected(client, auth_headers, test_db):
    """DELETE /me/pantry/ingredients/{id} for item not in pantry returns 404."""
    eggs = test_db.query(Ingredient).filter_by(name="eggs").first()

    response = client.delete(
        f"/me/pantry/ingredients/{eggs.id}",
        headers=auth_headers,
    )

    assert response.status_code == 404
