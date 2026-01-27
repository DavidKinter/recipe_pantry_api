"""
GenAI-endpoints for Recipe Pantry API.

Exposes the /ai/dish-suggestions endpoint for GenAI features.
"""

import os

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from src import models
from src.database import get_db
from src.dependencies import get_current_user
from src.helpers.pantry_helpers import get_user_pantry
from src.schemas import DishSuggestionResponse
from src.services.pantry_ai import get_dish_suggestions

router = APIRouter(prefix="/ai", tags=["Pantry AI"])


@router.post("/dish-suggestions", response_model=DishSuggestionResponse)
async def dish_suggestions(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    V2 GenAI Feature: Get AI-powered dish suggestions
    based on what's in your pantry

    Returns dishes at three purchase tiers:
    - buy_one: dish needing 1 more ingredient
    - buy_two: dish needing 2 more ingredients
    - buy_three: dish needing 3 more ingredients
    """
    # Checks if Claude API key is set
    if not os.getenv("ANTHROPIC_API_KEY"):
        raise HTTPException(
            status_code=503, detail="AI service not configured"
        )

    # Get user's pantry items
    pantry_items = get_user_pantry(current_user.id, db)

    if not pantry_items:
        raise HTTPException(
            status_code=400,
            detail="Your pantry is empty. Add ingredients first!",
        )

    # Extract ingredient names
    pantry_names = []
    for item in pantry_items:
        pantry_names.append(item.ingredient_name)

    # Get AI suggestions
    suggestions = await get_dish_suggestions(pantry_names)

    return suggestions
