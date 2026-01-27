"""
Tests for GenAI dish suggestion endpoint.

Uses mocking to avoid real Claude API calls during testing.
"""

import json
from unittest.mock import AsyncMock, Mock, patch

from src.models import Ingredient
from src.services import pantry_ai


def test_dish_suggestions_with_mocked_ai(client, auth_headers, test_db):
    """Tests dish suggestions without calling Claude API."""

    # Creates mock response that looks like Claude's response
    mock_ai_response = {
        "buy_one": {"dish": "Pancakes", "missing": ["baking powder"]},
        "buy_two": {"dish": "Carbonara", "missing": ["parmesan", "bacon"]},
        "buy_three": {
            "dish": "Shakshuka",
            "missing": ["tomatoes", "peppers", "cumin"],
        },
    }

    # Patches the client's beta.messages.create method
    with patch.object(
        pantry_ai.client.beta.messages, "create", new_callable=AsyncMock
    ) as mock_create:
        # Configures mock to return our fake response
        # Claude response structure: content[0].text
        mock_create.return_value = Mock(
            content=[Mock(text=json.dumps(mock_ai_response))]
        )

        # Adds items to pantry first (look up ingredient IDs from test_db)
        milk = test_db.query(Ingredient).filter_by(name="milk").first()
        eggs = test_db.query(Ingredient).filter_by(name="eggs").first()
        client.post(
            "/me/pantry/ingredients",
            headers=auth_headers,
            json={"ingredient_id": milk.id},
        )
        client.post(
            "/me/pantry/ingredients",
            headers=auth_headers,
            json={"ingredient_id": eggs.id},
        )

        # Calls pantry AI endpoint
        response = client.post("/ai/dish-suggestions", headers=auth_headers)

        assert response.status_code == 200
        suggestions = response.json()["suggestions"]
        assert suggestions["buy_one"]["dish"] == "Pancakes"
        assert suggestions["buy_two"]["dish"] == "Carbonara"
        assert suggestions["buy_three"]["dish"] == "Shakshuka"


def test_dish_suggestions_handles_ai_failure(client, auth_headers, test_db):
    """Should handle Claude API failures gracefully"""

    # Patches the beta.messages.create method to raise an exception
    with patch.object(
        pantry_ai.client.beta.messages, "create", new_callable=AsyncMock
    ) as mock_create:
        # Configure mock to raise on create()
        mock_create.side_effect = Exception("Claude API is down")

        # Adds pantry items (look up ingredient ID from test_db)
        eggs = test_db.query(Ingredient).filter_by(name="eggs").first()
        client.post(
            "/me/pantry/ingredients",
            headers=auth_headers,
            json={"ingredient_id": eggs.id},
        )

        response = client.post("/ai/dish-suggestions", headers=auth_headers)

        # Should return 200 error, not 500
        assert response.status_code == 200
        result = response.json()
        assert "error" in result


def test_dish_suggestions_empty_pantry_rejected(client, auth_headers, test_db):
    """POST /ai/dish-suggestions with empty pantry should return 400."""
    # Don't add anything to pantry - it's empty by default
    response = client.post("/ai/dish-suggestions", headers=auth_headers)

    assert response.status_code == 400
    assert "empty" in response.json()["detail"].lower()
