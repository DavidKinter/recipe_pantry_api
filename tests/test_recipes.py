"""Recipe CRUD endpoint tests."""


def test_create_recipe(client, auth_headers, test_db):
    """POST /me/recipes should create a new recipe."""

    # Creates a recipe first
    response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Test Scrambled Eggs",
            "ingredients_json": [  # Seeded by test_db fixture
                "eggs",
                "butter",
            ],
            "instructions": "Beat eggs, cook in butter",
            "prep_minutes": 10,
            "is_public": False,
        },
    )

    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Scrambled Eggs"
    assert len(data["ingredients_json"]) == 2


def test_create_recipe_invalid_ingredient_rejected(
    client,
    auth_headers,
    test_db,
):
    """POST /me/recipes with non-existent ingredient should return 400."""

    # Creates a recipe first
    response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Invalid Recipe",
            "ingredients_json": [  # eggs seeded, unicorn_tears NOT (tests rejection)
                "eggs",
                "unicorn_tears",
            ],
            "instructions": "Won't work",
            "prep_minutes": 5,
            "is_public": False,
        },
    )

    # 400 Bad Request = valid JSON structure, but fails business logic validation
    assert response.status_code == 400


def test_get_user_recipes(client, auth_headers, test_db):
    """GET /me/recipes should return user's recipes."""

    # Creates a recipe first
    client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "My Recipe",
            "ingredients_json": [  # Seeded by test_db fixture
                "eggs"
            ],
            "instructions": "Cook it",
            "prep_minutes": 5,
            "is_public": False,
        },
    )

    # Then fetches all recipes
    response = client.get("/me/recipes", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["title"] == "My Recipe"


def test_delete_recipe(client, auth_headers, test_db):
    """DELETE /me/recipes/{id} should remove the recipe."""

    # Creates a recipe first
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "To Be Deleted",
            "ingredients_json": [  # Seeded by test_db fixture
                "eggs"
            ],
            "instructions": "Goodbye",
            "prep_minutes": 1,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Deletes recipe
    delete_response = client.delete(
        f"/me/recipes/{recipe_id}",
        headers=auth_headers,
    )

    # API returns 200 with confirmation message, not 204
    assert delete_response.status_code == 200
    assert "deleted" in delete_response.json()["message"]


def test_update_recipe(client, auth_headers, test_db):
    """PUT /me/recipes/{id} should update recipe details."""

    # Create a recipe first
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Original Title",
            "ingredients_json": ["eggs"],
            "instructions": "Original instructions",
            "prep_minutes": 10,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Update the recipe title
    update_response = client.put(
        f"/me/recipes/{recipe_id}",
        headers=auth_headers,
        json={"title": "Updated Title"},
    )

    assert update_response.status_code == 200
    data = update_response.json()
    assert data["title"] == "Updated Title"
    # Other fields should remain unchanged
    assert data["instructions"] == "Original instructions"


def test_update_recipe_not_found(client, auth_headers, test_db):
    """PUT /me/recipes/{id} should return 404 for non-existent recipe."""

    response = client.put(
        "/me/recipes/99999",
        headers=auth_headers,
        json={"title": "Won't Work"},
    )

    assert response.status_code == 404


def test_update_recipe_not_owner_rejected(
    client, auth_headers, second_auth_headers, test_db
):
    """PUT /me/recipes/{id} should return 403 for another user's recipe."""

    # Creates a recipe with the first user (test_user via auth_headers)
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "First User Recipe",
            "ingredients_json": ["eggs"],
            "instructions": "My recipe",
            "prep_minutes": 5,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Tries to update first user's recipe with second user's credentials
    response = client.put(
        f"/me/recipes/{recipe_id}",
        headers=second_auth_headers,
        json={"title": "Stolen Recipe"},
    )

    # 403 at resource level = "you're authenticated but don't own this resource"
    assert response.status_code == 403


def test_delete_recipe_not_found(client, auth_headers, test_db):
    """DELETE /me/recipes/{id} should return 404 for non-existent recipe."""
    response = client.delete(
        "/me/recipes/99999",
        headers=auth_headers,
    )

    assert response.status_code == 404


def test_admin_get_recipe_by_id(client, admin_headers, auth_headers, test_db):
    """GET /recipes/{id} should return recipe for admin."""
    # Create a recipe first
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Admin View Recipe",
            "ingredients_json": ["eggs"],
            "instructions": "Test instructions",
            "prep_minutes": 5,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Admin fetches it
    response = client.get(f"/recipes/{recipe_id}", headers=admin_headers)

    assert response.status_code == 200
    assert response.json()["title"] == "Admin View Recipe"


def test_admin_update_recipe(client, admin_headers, auth_headers, test_db):
    """PUT /recipes/{id} should update any recipe for admin."""
    # Creates a recipe first
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "To Be Admin Updated",
            "ingredients_json": ["eggs"],
            "instructions": "Original",
            "prep_minutes": 5,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Admin updates it
    response = client.put(
        f"/recipes/{recipe_id}",
        headers=admin_headers,
        json={"instructions": "Admin updated this"},
    )

    assert response.status_code == 200
    assert response.json()["instructions"] == "Admin updated this"


def test_admin_delete_recipe(client, admin_headers, auth_headers, test_db):
    """DELETE /recipes/{id} should delete any recipe for admin."""
    # Creates a recipe first
    create_response = client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Admin Will Delete",
            "ingredients_json": ["eggs"],
            "instructions": "Goodbye",
            "prep_minutes": 5,
            "is_public": False,
        },
    )
    recipe_id = create_response.json()["id"]

    # Admin deletes it
    response = client.delete(f"/recipes/{recipe_id}", headers=admin_headers)

    assert response.status_code == 200
    assert "deleted" in response.json()["message"]


def test_admin_get_recipe_not_found(client, admin_headers, test_db):
    """GET /recipes/{id} should return 404 for non-existent recipe."""
    response = client.get("/recipes/99999", headers=admin_headers)

    assert response.status_code == 404


def test_admin_update_recipe_not_found(client, admin_headers, test_db):
    """PUT /recipes/{id} should return 404 for non-existent recipe."""
    response = client.put(
        "/recipes/99999",
        headers=admin_headers,
        json={"title": "Won't Work"},
    )

    assert response.status_code == 404


def test_admin_delete_recipe_not_found(client, admin_headers, test_db):
    """DELETE /recipes/{id} should return 404 for non-existent recipe."""
    response = client.delete("/recipes/99999", headers=admin_headers)

    assert response.status_code == 404
