"""
User management endpoints - Profile and admin operations.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from src import models, schemas
from src.database import get_db
from src.dependencies import get_current_user, require_admin
from src.helpers.user_helpers import (
    apply_user_updates,
    check_email_exists,
    check_username_exists,
    find_user_by_id,
    remove_user_from_database,
)

router = APIRouter()


# ===== USER SELF-MANAGEMENT ENDPOINTS (/me) =====


@router.get("/me", response_model=schemas.User, tags=["User Profile"])
def get_current_user_profile(
    current_user: models.User = Depends(get_current_user),
):
    """Get the current user's profile."""
    return current_user


@router.put("/me", response_model=schemas.User, tags=["User Profile"])
def update_current_user_profile(
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update the current user's profile."""
    update_data = user_update.model_dump(exclude_unset=True)
    updated_user = apply_user_updates(current_user, update_data, db)
    return updated_user


@router.delete("/me", tags=["User Profile"])
def delete_current_user_account(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Delete the current user's account (CASCADE deletes recipes + pantry).
    Admins cannot delete their own account for safety.
    """
    # Prevent admins from deleting themselves
    if current_user.role == "admin":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin accounts cannot be self-deleted for safety. Contact another admin.",
        )

    # Delete the user with CASCADE verification
    deletion_stats = remove_user_from_database(current_user, db)

    return {
        "message": "Your account has been deleted",
        "recipes_deleted": deletion_stats["recipes_deleted"],
        "pantry_items_deleted": deletion_stats["pantry_items_deleted"],
    }


# ===== ADMIN USER MANAGEMENT ENDPOINTS =====


@router.get(
    "/users", response_model=list[schemas.User], tags=["Admin - Users"]
)
def get_users(
    skip: int = 0,
    limit: int = 100,
    admin: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    """Get a paginated list of all users in the system. Admin access required."""
    return db.query(models.User).offset(skip).limit(limit).all()


@router.get(
    "/users/{user_id}", response_model=schemas.User, tags=["Admin - Users"]
)
def get_user(
    user_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Gets one user by their ID. Admin access only."""
    # Check admin permission
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )

    # Find the user
    user = find_user_by_id(user_id, db)
    if not user:
        raise HTTPException(404, f"No user with ID {user_id}")

    return user


@router.put(
    "/users/{user_id}", response_model=schemas.User, tags=["Admin - Users"]
)
def update_user(
    user_id: int,
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update a user's information by their ID. Admin access required."""
    try:
        # Check admin permission
        if current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Admin access required. Only administrators can update user accounts.",
            )

        # Find the user to update
        user = find_user_by_id(user_id, db)

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found",
            )

        # Get only the fields that were sent
        update_data = user_update.model_dump(exclude_unset=True)

        # Check if updating email to one that already exists
        if (
            "email" in update_data
            and update_data["email"] != user.email
            and check_email_exists(update_data["email"], db)
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Email '{update_data['email']}' is already registered to another user",
            )

        # Check if updating username to one that already exists
        if (
            "username" in update_data
            and update_data["username"] != user.username
            and check_username_exists(update_data["username"], db)
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Username '{update_data['username']}' is already taken",
            )

        # Apply the updates
        updated_user = apply_user_updates(user, update_data, db)
        return updated_user

    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        if "email" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email address is already in use",
            )
        if "username" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username is already taken",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Database constraint violation: {e.orig!s}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error updating user: {e!s}",
        )


@router.delete("/users/{user_id}", tags=["Admin - Users"])
def delete_user(
    user_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Delete a user account by their ID. Admin access required.
    Cannot delete admin accounts for safety.
    """
    # Check admin permission
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )

    # Prevent admin from deleting themselves
    if current_user.id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own admin account",
        )

    # Find the user to delete
    user = find_user_by_id(user_id, db)

    if not user:
        raise HTTPException(404, f"No user with ID {user_id}")

    # Prevent deletion of any admin account
    if user.role == "admin":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin accounts cannot be deleted through the API for safety",
        )

    # Delete the user with CASCADE verification
    deletion_stats = remove_user_from_database(user, db)

    return {
        "message": f"User {user_id} was deleted",
        "recipes_deleted": deletion_stats["recipes_deleted"],
        "pantry_items_deleted": deletion_stats["pantry_items_deleted"],
    }
