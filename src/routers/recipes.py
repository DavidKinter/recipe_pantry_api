"""
Recipe management endpoints - CRUD operations and matching.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from src import models, schemas
from src.database import get_db
from src.dependencies import get_current_user, require_admin
from src.helpers.pantry_helpers import get_user_pantry
from src.helpers.recipe_helpers import (
    create_recipe_in_database,
    delete_recipe_from_database,
    find_recipe_by_id,
    get_visible_recipes,
    update_recipe_in_database,
)

router = APIRouter()


# ===== USER RECIPE ENDPOINTS =====


@router.post(
    "/me/recipes",
    response_model=schemas.Recipe,
    status_code=status.HTTP_201_CREATED,
    tags=["User - Recipes"],
)
def create_recipe(
    recipe: schemas.RecipeCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Create a new recipe.
    - Requires authentication
    - Ingredients are normalized to lowercase
    - Recipe is private by default
    """
    try:
        # Check if user already has a recipe with this title
        existing_recipe = (
            db.query(models.Recipe)
            .filter(
                models.Recipe.user_id == current_user.id,
                models.Recipe.title == recipe.title,
            )
            .first()
        )

        if existing_recipe:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"You already have a recipe called '{recipe.title}'. "
                f"Please choose a different title or update the existing recipe.",
            )

        new_recipe = create_recipe_in_database(recipe, current_user.id, db)
        return new_recipe

    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        if "unique_recipe_title_per_user" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"You already have a recipe called '{recipe.title}'. "
                f"Please choose a different title or update the existing recipe.",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Database constraint violation: {e.orig!s}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error creating recipe: {e!s}",
        )


@router.get(
    "/me/recipes",
    response_model=list[schemas.Recipe],
    tags=["User - Recipes"],
)
def get_my_recipes(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get all recipes owned by the current user.
    - Returns both public and private recipes
    - Only shows recipes created by the authenticated user
    """
    recipes = (
        db.query(models.Recipe)
        .filter(models.Recipe.user_id == current_user.id)
        .offset(skip)
        .limit(limit)
        .all()
    )
    return recipes


@router.get(
    "/me/recipes/available",
    response_model=schemas.RecipeMatchResponse,
    tags=["User - Recipes"],
)
def get_available_recipes_based_on_pantry(
    threshold: float = 0.5,
    limit: int = 20,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get recipes you can make based on pantry contents.
    """
    # Validates threshold
    if not 0 <= threshold <= 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Threshold must be between 0 and 1",
        )

    # Get user's pantry
    pantry_entries = get_user_pantry(current_user.id, db)

    # Build set of all ingredient names user has (including synonyms)
    user_has_ingredients = set()
    for pantry_entry in pantry_entries:
        user_has_ingredients.add(pantry_entry.ingredient_name)

        # Look up the ingredient to get synonyms
        ingredient = (
            db.query(models.Ingredient)
            .filter(models.Ingredient.id == pantry_entry.ingredient_id)
            .first()
        )

        # Add all synonyms too
        if ingredient and ingredient.synonyms:
            user_has_ingredients.update(ingredient.synonyms)

    # Get all visible recipes
    recipes = get_visible_recipes(current_user, db, limit=None)

    # Calculate matches
    matches = []
    for recipe in recipes:
        recipe_ingredients = set(recipe.ingredients_json)

        # Calculate match details
        available_ingredients = user_has_ingredients.intersection(
            recipe_ingredients
        )
        missing_ingredients = recipe_ingredients - user_has_ingredients
        match_percentage = len(available_ingredients) / len(recipe_ingredients)

        # Must have at least 1 ingredient AND meet threshold percentage
        has_minimum_match = len(available_ingredients) >= 1
        meets_threshold = match_percentage >= threshold

        if has_minimum_match and meets_threshold:
            is_own = recipe.user_id == current_user.id
            match = schemas.RecipeMatch(
                title=recipe.title,
                prep_minutes=recipe.prep_minutes,
                instructions=recipe.instructions,
                ingredients_json=list(recipe.ingredients_json),
                ingredients_total=len(recipe_ingredients),
                ingredients_available=len(available_ingredients),
                ingredients_missing=len(missing_ingredients),
                available_ingredients=sorted(available_ingredients),
                missing_ingredients=sorted(missing_ingredients),
                is_own_recipe=is_own,
            )
            matches.append(match)

    # Sort by match percentage (descending)
    matches.sort(
        key=lambda x: x.ingredients_available / x.ingredients_total,
        reverse=True,
    )

    # Build list of pantry ingredient names
    pantry_names = []
    for entry in pantry_entries:
        pantry_names.append(entry.ingredient_name)

    # Return top N best matches only
    return schemas.RecipeMatchResponse(
        recipes=matches[:limit],
        threshold=threshold,
        user_pantry=sorted(pantry_names),
    )


@router.put(
    "/me/recipes/{recipe_id}",
    response_model=schemas.Recipe,
    tags=["User - Recipes"],
)
def update_my_recipe(
    recipe_id: int,
    recipe_update: schemas.RecipeUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Update your own recipe.
    - Only the recipe owner can update
    - All fields are optional
    """
    try:
        # Check ownership
        recipe = find_recipe_by_id(recipe_id, db)

        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recipe with ID {recipe_id} not found",
            )

        if recipe.user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to update this recipe. You can only update your own recipes.",
            )

        update_data = recipe_update.model_dump(exclude_unset=True)

        # Check if changing title to one that already exists
        if "title" in update_data and update_data["title"] != recipe.title:
            existing_recipe = (
                db.query(models.Recipe)
                .filter(
                    models.Recipe.user_id == current_user.id,
                    models.Recipe.title == update_data["title"],
                    models.Recipe.id != recipe_id,
                )
                .first()
            )

            if existing_recipe:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"You already have another recipe called '{update_data['title']}'. "
                    f"Please choose a different title.",
                )

        if update_data:
            updated_recipe = update_recipe_in_database(recipe, update_data, db)
            return updated_recipe

        return recipe

    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Update failed - constraint violation: {e.orig!s}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error during update: {e!s}",
        )


@router.delete(
    "/me/recipes/{recipe_id}",
    tags=["User - Recipes"],
)
def delete_my_recipe(
    recipe_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Delete your own recipe.
    - Only the recipe owner can delete
    - Returns confirmation with recipe title
    """
    try:
        recipe = find_recipe_by_id(recipe_id, db)

        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recipe with ID {recipe_id} not found",
            )

        if recipe.user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to delete this recipe. You can only delete your own recipes.",
            )

        # Store recipe title before deletion
        recipe_title = recipe.title
        delete_recipe_from_database(recipe, db)

        return {
            "message": f"Recipe '{recipe_title}' was deleted successfully",
            "recipe_id": recipe_id,
        }

    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete recipe: {e!s}",
        )


# ===== ADMIN RECIPE ENDPOINTS =====


@router.get(
    "/recipes",
    response_model=list[schemas.Recipe],
    tags=["Admin - Recipes"],
)
def get_recipes(
    skip: int = 0,
    limit: int = 100,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    Get all recipes in the database.
    Admin access only - returns all recipes (public and private).
    """
    recipes = db.query(models.Recipe).offset(skip).limit(limit).all()
    return recipes


@router.get(
    "/recipes/{recipe_id}",
    response_model=schemas.Recipe,
    tags=["Admin - Recipes"],
)
def get_recipe(
    recipe_id: int,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    Get a specific recipe by ID.
    Admin access only - can view any recipe.
    """
    recipe = find_recipe_by_id(recipe_id, db)

    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Recipe not found",
        )

    return recipe


@router.put(
    "/recipes/{recipe_id}",
    response_model=schemas.Recipe,
    tags=["Admin - Recipes"],
)
def update_recipe(
    recipe_id: int,
    recipe_update: schemas.RecipeUpdate,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    Update any recipe.
    Admin access only.
    """
    try:
        recipe = find_recipe_by_id(recipe_id, db)

        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recipe with ID {recipe_id} not found",
            )

        update_data = recipe_update.model_dump(exclude_unset=True)

        # Check if changing title to one that already exists for the recipe owner
        if "title" in update_data and update_data["title"] != recipe.title:
            existing_recipe = (
                db.query(models.Recipe)
                .filter(
                    models.Recipe.user_id == recipe.user_id,
                    models.Recipe.title == update_data["title"],
                    models.Recipe.id != recipe_id,
                )
                .first()
            )

            if existing_recipe:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"User already has another recipe called '{update_data['title']}'. "
                    f"Cannot create duplicate.",
                )

        if update_data:
            updated_recipe = update_recipe_in_database(recipe, update_data, db)
            return updated_recipe

        return recipe

    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Update failed - database constraint violation: {e.orig!s}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error during recipe update: {e!s}",
        )


@router.delete(
    "/recipes/{recipe_id}",
    tags=["Admin - Recipes"],
)
def delete_recipe(
    recipe_id: int,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """
    Delete any recipe.
    Admin access only - returns confirmation with recipe details.
    """
    try:
        recipe = find_recipe_by_id(recipe_id, db)

        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recipe with ID {recipe_id} not found. Please check the recipe ID and try again.",
            )

        # Store recipe details before deletion
        recipe_title = recipe.title
        recipe_owner_id = recipe.user_id
        delete_recipe_from_database(recipe, db)

        return {
            "message": f"Recipe '{recipe_title}' (ID {recipe_id}) deleted by admin",
            "recipe_id": recipe_id,
            "owner_user_id": recipe_owner_id,
        }

    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete recipe: {e!s}",
        )


# ===== INGREDIENT REFERENCE ENDPOINT =====


@router.get(
    "/ingredients",
    response_model=list[schemas.Ingredient],
    tags=["System"],
)
def get_ingredients(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Get all available ingredients with ID and name.
    Returns complete alphabetically-sorted reference list.
    """
    ingredients = (
        db.query(models.Ingredient).order_by(models.Ingredient.name).all()
    )
    return ingredients
