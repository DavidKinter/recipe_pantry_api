"""
Pantry management endpoints.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from src import models, schemas
from src.database import get_db
from src.dependencies import get_current_user
from src.helpers.pantry_helpers import (
    add_ingredient_to_pantry,
    get_user_pantry,
    remove_ingredient_from_pantry,
    replace_pantry_ingredients,
)

router = APIRouter()


@router.get(
    "/me/pantry",
    response_model=schemas.PantryResponse,
    tags=["User - Pantry"],
)
def get_pantry(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get user's pantry contents as array.
    Returns list of pantry ingredients with id and name.
    """
    pantry_entries = get_user_pantry(current_user.id, db)

    ingredients_list = []
    for entry in pantry_entries:
        ingredients_list.append(
            schemas.PantryIngredient(
                ingredient_id=entry.ingredient_id,
                ingredient_name=entry.ingredient_name,
            )
        )

    return schemas.PantryResponse(ingredients=ingredients_list)


@router.post(
    "/me/pantry/ingredients",
    response_model=schemas.PantryIngredient,
    status_code=status.HTTP_201_CREATED,
    tags=["User - Pantry"],
)
def add_pantry_ingredient(
    ingredient: schemas.PantryAddItem,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Add a single ingredient to your pantry by ingredient ID.
    - Ingredient must exist in ingredients table
    - Cannot add duplicates
    """
    try:
        pantry_entry = add_ingredient_to_pantry(
            current_user.id,
            ingredient.ingredient_id,
            db,
        )
        return schemas.PantryIngredient(
            ingredient_id=pantry_entry.ingredient_id,
            ingredient_name=pantry_entry.ingredient_name,
        )
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error adding ingredient: {e!s}",
        )


@router.delete(
    "/me/pantry/ingredients/{ingredient_id}",
    tags=["User - Pantry"],
)
def remove_pantry_ingredient(
    ingredient_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Remove a single ingredient from your pantry by ingredient ID.
    Returns confirmation with ingredient name.
    """
    try:
        # Look up ingredient name before deletion
        pantry_entry = (
            db.query(models.UserPantry)
            .filter(
                models.UserPantry.user_id == current_user.id,
                models.UserPantry.ingredient_id == ingredient_id,
            )
            .first()
        )

        if not pantry_entry:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Ingredient ID {ingredient_id} not found in your pantry",
            )

        ingredient_name = pantry_entry.ingredient_name
        remove_ingredient_from_pantry(current_user.id, ingredient_id, db)

        return {
            "message": f"'{ingredient_name}' removed from pantry",
            "ingredient_id": ingredient_id,
        }
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error removing ingredient: {e!s}",
        )


@router.put(
    "/me/pantry",
    response_model=schemas.PantryResponse,
    tags=["User - Pantry"],
)
def replace_pantry(
    pantry_update: schemas.PantryUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Replace entire pantry with new ingredient list by IDs.
    - Atomic operation: All IDs must be valid or nothing changes
    - Returns 400 error listing any invalid IDs
    - Use GET /ingredients to see all valid ingredient IDs
    """
    try:
        # Validate input
        if not isinstance(pantry_update.ingredient_ids, list):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="ingredient_ids must be a list",
            )

        # Replace pantry
        new_entries = replace_pantry_ingredients(
            current_user.id,
            pantry_update.ingredient_ids,
            db,
        )

        # Build response array
        ingredients_list = []
        for entry in new_entries:
            ingredients_list.append(
                schemas.PantryIngredient(
                    ingredient_id=entry.ingredient_id,
                    ingredient_name=entry.ingredient_name,
                )
            )

        return schemas.PantryResponse(ingredients=ingredients_list)
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error updating pantry: {e!s}",
        )
