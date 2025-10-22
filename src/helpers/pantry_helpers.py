"""
Pantry-related helper functions.
"""

from typing import List

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from src import models


def get_user_pantry(user_id: int, db: Session) -> List[models.UserPantry]:
    """Gets all pantry entries for a user."""
    return (
        db.query(models.UserPantry)
        .filter(models.UserPantry.user_id == user_id)
        .all()
    )


def add_ingredient_to_pantry(
    user_id: int,
    ingredient_id: int,
    db: Session,
) -> models.UserPantry:
    """Adds a single ingredient to user's pantry."""
    ingredient = (
        db.query(models.Ingredient)
        .filter(models.Ingredient.id == ingredient_id)
        .first()
    )

    if not ingredient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ingredient with ID {ingredient_id} not found",
        )

    existing = (
        db.query(models.UserPantry)
        .filter(
            models.UserPantry.user_id == user_id,
            models.UserPantry.ingredient_id == ingredient_id,
        )
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"'{ingredient.name}' is already in your pantry",
        )

    pantry_entry = models.UserPantry(
        user_id=user_id,
        ingredient_id=ingredient_id,
        ingredient_name=ingredient.name,
    )

    db.add(pantry_entry)
    db.commit()
    db.refresh(pantry_entry)
    return pantry_entry


def remove_ingredient_from_pantry(
    user_id: int,
    ingredient_id: int,
    db: Session,
) -> None:
    """Removes a single ingredient from user's pantry."""
    pantry_entry = (
        db.query(models.UserPantry)
        .filter(
            models.UserPantry.user_id == user_id,
            models.UserPantry.ingredient_id == ingredient_id,
        )
        .first()
    )

    if not pantry_entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ingredient ID {ingredient_id} not found in your pantry",
        )

    db.delete(pantry_entry)
    db.commit()


def replace_pantry_ingredients(
    user_id: int,
    ingredient_ids: List[int],
    db: Session,
) -> List[models.UserPantry]:
    """
    Replaces entire pantry with new ingredient list.
    ATOMIC OPERATION: Either all ingredients are valid or none are changed.
    """
    # Validate ALL ingredient IDs exist
    invalid_ids = []
    valid_ingredients = {}

    for ingredient_id in ingredient_ids:
        ingredient = (
            db.query(models.Ingredient)
            .filter(models.Ingredient.id == ingredient_id)
            .first()
        )

        if not ingredient:
            invalid_ids.append(ingredient_id)
        else:
            valid_ingredients[ingredient_id] = ingredient

    if invalid_ids:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid ingredient IDs: {invalid_ids}. Use GET /ingredients to see all valid IDs.",
        )

    # Delete old pantry
    db.query(models.UserPantry).filter(
        models.UserPantry.user_id == user_id,
    ).delete()

    # Create new pantry entries
    new_entries = []
    for ingredient_id in ingredient_ids:
        ingredient = valid_ingredients[ingredient_id]
        pantry_entry = models.UserPantry(
            user_id=user_id,
            ingredient_id=ingredient_id,
            ingredient_name=ingredient.name,
        )
        db.add(pantry_entry)
        new_entries.append(pantry_entry)

    db.commit()
    return new_entries
