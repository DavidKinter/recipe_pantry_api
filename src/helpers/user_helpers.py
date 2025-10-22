"""
User-related helper functions.
"""

from typing import Optional

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from src import models
from src.auth import create_access_token
from src.auth_utils import hash_password


def check_email_exists(email: str, db: Session) -> bool:
    """Checks if email is already in database."""
    user_with_email = (
        db.query(models.User).filter(models.User.email == email).first()
    )
    return user_with_email is not None


def check_username_exists(username: str, db: Session) -> bool:
    """Checks if username is already taken."""
    user_with_username = (
        db.query(models.User).filter(models.User.username == username).first()
    )
    return user_with_username is not None


def find_user_by_id(user_id: int, db: Session) -> Optional[models.User]:
    """Finds a user by their ID number."""
    found_user = (
        db.query(models.User).filter(models.User.id == user_id).first()
    )
    return found_user


def find_user_by_email(email: str, db: Session) -> Optional[models.User]:
    """Finds a user by their email address."""
    found_user = (
        db.query(models.User).filter(models.User.email == email).first()
    )
    return found_user


def apply_user_updates(
    user: models.User,
    updates: dict,
    db: Session,
) -> models.User:
    """Updates user fields with new values."""
    for field_name, new_value in updates.items():
        setattr(user, field_name, new_value)
    db.commit()
    db.refresh(user)
    return user


def remove_user_from_database(user: models.User, db: Session) -> dict:
    """
    Deletes a user from the database with CASCADE verification.
    Returns counts of CASCADE-deleted items for transparency.
    """
    recipe_count = len(user.recipes)
    pantry_count = len(user.user_pantry)

    db.delete(user)
    db.commit()

    return {
        "recipes_deleted": recipe_count,
        "pantry_items_deleted": pantry_count,
    }


def create_user_with_hashed_password(
    user_data, db: Session, role: str = "user"
) -> models.User:
    """Creates new user with properly hashed password."""
    new_user_record = models.User(
        email=user_data.email,
        username=user_data.username,
        password_hash=hash_password(user_data.password),
        role=role,
    )
    db.add(new_user_record)
    db.commit()
    db.refresh(new_user_record)
    return new_user_record


def create_user_token(user: models.User) -> dict:
    """Creates a JWT token containing user information."""
    token_data = {"sub": str(user.id), "email": user.email}
    access_token = create_access_token(token_data)
    return {"access_token": access_token, "token_type": "bearer"}


def check_user_permission(current_user_id: int, target_user_id: int) -> None:
    """Checks if current user has permission to modify target user."""

    if current_user_id != target_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only modify your own account",
        )
