"""Recipe matching endpoint tests."""

from src.models import Ingredient


def test_get_available_recipes(client, auth_headers, test_db, test_recipe):
    """GET /me/recipes/available should return matching recipes."""
    # test_recipe creates "Simple Eggs" with ingredient "eggs"
    eggs = test_db.query(Ingredient).filter_by(name="eggs").first()
    client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": eggs.id},
    )

    response = client.get("/me/recipes/available", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert len(data["recipes"]) >= 1
    titles = [r["title"] for r in data["recipes"]]
    assert "Simple Eggs" in titles


def test_available_recipes_invalid_threshold(client, auth_headers):
    """GET /me/recipes/available with threshold > 1 should return 400."""
    response = client.get(
        "/me/recipes/available?threshold=1.5",
        headers=auth_headers,
    )

    assert response.status_code == 400


def test_matching_with_synonyms(client, auth_headers, test_db):
    """Synonym matching: user with 'milk' should match recipe needing 'whole milk'."""
    # Adds "whole milk" as a valid ingredient (needed for recipe creation)
    whole_milk = Ingredient(name="whole milk")
    test_db.add(whole_milk)

    # Updates existing milk ingredient with synonyms (seeded without them)
    existing_milk = test_db.query(Ingredient).filter_by(name="milk").first()
    existing_milk.synonyms = ["whole milk", "skim milk", "2% milk"]
    test_db.commit()

    # Creates recipe that uses a SYNONYM (not the base ingredient name)
    client.post(
        "/me/recipes",
        headers=auth_headers,
        json={
            "title": "Cereal Bowl",
            "ingredients_json": ["whole milk"],
            "instructions": "Pour milk over cereal",
            "prep_minutes": 2,
            "is_public": True,
        },
    )

    # Adds the BASE ingredient (milk) to pantry
    client.post(
        "/me/pantry/ingredients",
        headers=auth_headers,
        json={"ingredient_id": existing_milk.id},
    )

    # Should match because milk's synonyms include "whole milk"
    response = client.get("/me/recipes/available", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    titles = [r["title"] for r in data["recipes"]]
    assert "Cereal Bowl" in titles


def test_matching_empty_pantry(client, auth_headers, test_recipe):
    """Empty pantry should return no matching recipes."""
    # test_recipe exists but pantry is empty - should get no matches
    response = client.get("/me/recipes/available", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert len(data["recipes"]) == 0
