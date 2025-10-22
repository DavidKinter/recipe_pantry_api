"""
Recipe-related helper functions.
"""

from typing import List, Optional

from fastapi import HTTPException, status
from sqlalchemy import or_ as db_or
from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from src import models, schemas


def find_ingredient_by_name(
    name: str, db: Session
) -> Optional[models.Ingredient]:
    """
    Looks up an ingredient by name (case-insensitive).
    Returns None if not found - does NOT create new ingredients.
    """
    normalized_name = name.lower().strip()
    return (
        db.query(models.Ingredient)
        .filter(models.Ingredient.name == normalized_name)
        .first()
    )


def populate_recipe_ingredients(
    recipe_id: int,
    ingredient_names: List[str],
    db: Session,
) -> List[str]:
    """
    Populates recipe_ingredients junction table from ingredient names.
    Returns list of successfully linked ingredient names.
    """
    linked_ingredients = []

    for name in ingredient_names:
        if not name.strip():
            continue

        ingredient = find_ingredient_by_name(name, db)
        if not ingredient:
            continue

        existing_link = (
            db.query(models.RecipeIngredient)
            .filter(
                models.RecipeIngredient.recipe_id == recipe_id,
                models.RecipeIngredient.ingredient_id == ingredient.id,
            )
            .first()
        )

        if not existing_link:
            recipe = (
                db.query(models.Recipe)
                .filter(models.Recipe.id == recipe_id)
                .first()
            )

            recipe_ingredient = models.RecipeIngredient(
                recipe_id=recipe_id,
                ingredient_id=ingredient.id,
                recipe_name=recipe.title if recipe else "Unknown",
                ingredient_name=ingredient.name,
            )
            db.add(recipe_ingredient)
            linked_ingredients.append(ingredient.name)

    return linked_ingredients


def update_recipes_ingredients_json(
    recipe: models.Recipe, db: Session
) -> None:
    """Updates the ORM-managed recipes.ingredients_json field."""
    recipe_ingredients = (
        db.query(models.RecipeIngredient)
        .filter(models.RecipeIngredient.recipe_id == recipe.id)
        .all()
    )

    ingredient_names = [ri.ingredient_name for ri in recipe_ingredients]
    recipe.ingredients_json = sorted(ingredient_names)
    flag_modified(recipe, "ingredients_json")


def check_recipe_ownership(recipe_id: int, user_id: int, db: Session) -> bool:
    """Checks if user owns the specified recipe."""
    recipe = (
        db.query(models.Recipe)
        .filter(
            models.Recipe.id == recipe_id,
            models.Recipe.user_id == user_id,
        )
        .first()
    )
    return recipe is not None


def find_recipe_by_id(recipe_id: int, db: Session) -> Optional[models.Recipe]:
    """Finds a recipe by ID."""
    return (
        db.query(models.Recipe).filter(models.Recipe.id == recipe_id).first()
    )


def create_recipe_in_database(
    recipe_data: schemas.RecipeCreate,
    user_id: int,
    db: Session,
) -> models.Recipe:
    """Creates new recipe and saves to database."""
    # Defense-in-depth: Filter out empty/whitespace ingredients FIRST
    valid_ingredients = []
    for ingredient_name in recipe_data.ingredients_json:
        cleaned = ingredient_name.strip()
        if cleaned:
            valid_ingredients.append(cleaned)

    if not valid_ingredients:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Recipe must have at least one valid ingredient. "
            "All provided ingredients were empty or whitespace. "
            f"Use GET /ingredients to see all {db.query(models.Ingredient).count()} valid options.",
        )

    # Validate ALL valid ingredients exist in database
    missing_ingredients = []
    for ingredient_name in valid_ingredients:
        ingredient = find_ingredient_by_name(ingredient_name, db)
        if not ingredient:
            missing_ingredients.append(ingredient_name)

    if missing_ingredients:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown ingredients: {', '.join(missing_ingredients)}. "
            f"Use GET /ingredients to see all {db.query(models.Ingredient).count()} valid options.",
        )

    # Create recipe
    db_recipe = models.Recipe(
        user_id=user_id,
        title=recipe_data.title,
        ingredients_json=[],
        instructions=recipe_data.instructions,
        prep_minutes=recipe_data.prep_minutes,
        is_public=recipe_data.is_public,
    )
    db.add(db_recipe)
    db.flush()

    # Populate recipe_ingredients junction table
    populate_recipe_ingredients(db_recipe.id, valid_ingredients, db)
    db.flush()

    # Update ORM-managed ingredients_json field
    update_recipes_ingredients_json(db_recipe, db)

    db.commit()
    db.refresh(db_recipe)
    return db_recipe


def update_recipe_in_database(
    recipe: models.Recipe,
    updates: dict,
    db: Session,
) -> models.Recipe:
    """Updates recipe fields with new values."""
    # Handle ingredients_json update separately
    if "ingredients_json" in updates:
        new_ingredients = updates.pop("ingredients_json")

        # Defense-in-depth: Filter out empty/whitespace ingredients
        valid_ingredients = []
        for ingredient_name in new_ingredients:
            cleaned = ingredient_name.strip()
            if cleaned:
                valid_ingredients.append(cleaned)

        if not valid_ingredients:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Recipe must have at least one valid ingredient. "
                "All provided ingredients were empty or whitespace. "
                f"Use GET /ingredients to see all {db.query(models.Ingredient).count()} valid options.",
            )

        # Validate ALL valid ingredients exist
        missing_ingredients = []
        for ingredient_name in valid_ingredients:
            ingredient = find_ingredient_by_name(ingredient_name, db)
            if not ingredient:
                missing_ingredients.append(ingredient_name)

        if missing_ingredients:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unknown ingredients: {', '.join(missing_ingredients)}. "
                f"Use GET /ingredients to see all {db.query(models.Ingredient).count()} valid options.",
            )

        # Delete existing recipe_ingredients
        db.query(models.RecipeIngredient).filter(
            models.RecipeIngredient.recipe_id == recipe.id,
        ).delete()

        # Populate with new ingredients
        populate_recipe_ingredients(recipe.id, valid_ingredients, db)

        # Update ORM-managed ingredients_json
        update_recipes_ingredients_json(recipe, db)

    # Update other fields
    for field, value in updates.items():
        setattr(recipe, field, value)

    db.commit()
    db.refresh(recipe)
    return recipe


def delete_recipe_from_database(recipe: models.Recipe, db: Session) -> None:
    """Deletes a recipe from the database."""
    db.delete(recipe)
    db.commit()


def get_visible_recipes(
    current_user: Optional[models.User],
    db: Session,
    skip: int = 0,
    limit: Optional[int] = 100,
) -> List[models.Recipe]:
    """Gets recipes visible to the current user."""
    if current_user:
        query = (
            db.query(models.Recipe)
            .filter(
                db_or(
                    models.Recipe.user_id == current_user.id,
                    models.Recipe.is_public == True,
                ),
            )
            .offset(skip)
        )

        if limit is not None:
            query = query.limit(limit)

        return query.all()

    # Not logged in: only public recipes
    query = (
        db.query(models.Recipe)
        .filter(models.Recipe.is_public == True)
        .offset(skip)
    )

    if limit is not None:
        query = query.limit(limit)

    return query.all()
