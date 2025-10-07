"""
Database Models - User Table Structure

Defines the User model for the database, according to the database schema.
Each User represents someone who can store recipes in the recipe pantry system.
"""

from sqlalchemy import JSON, Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from src.database import Base


# Week 1: User model only
class User(Base):  # pylint: disable=too-few-public-methods
    """
    User model for storing user account information.

    Represents a user in the recipe pantry system with email, username,
    password and automatic timestamp tracking for when accounts are
    created and updated.
    """

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default="user")
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
        # Updates 'updated_at' field
        onupdate=func.now(),  # pylint: disable=not-callable
    )

    # Week 3: Relationships
    recipes = relationship(
        "Recipe",
        back_populates="owner",
        cascade="all, delete-orphan",
    )
    pantry = relationship(
        "UserPantry",
        back_populates="owner",
        cascade="all, delete-orphan",
        uselist=False,
    )


# Week 3: Recipe model
class Recipe(Base):
    """
    Recipe model for storing cooking instructions and ingredients.
    Week 3: New model with JSONB for flexible ingredient storage.
    """

    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    title = Column(String(255), nullable=False)
    ingredients_json = Column(JSON, nullable=False, default=list)
    instructions = Column(Text, nullable=False)
    prep_minutes = Column(Integer, nullable=True)
    is_public = Column(Boolean, nullable=False, default=False)
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
        onupdate=func.now(),  # pylint: disable=not-callable
    )

    # Relationship back to User
    owner = relationship("User", back_populates="recipes")


# Week 3: UserPantry model
class UserPantry(Base):
    """
    UserPantry model for tracking what ingredients users have available.
    Week 3: New model with JSONB for flexible ingredient storage.
    """

    __tablename__ = "user_pantry"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    ingredients_json = Column(JSON, nullable=False, default=list)
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
        onupdate=func.now(),  # pylint: disable=not-callable
    )

    # Relationship back to User
    owner = relationship("User", back_populates="pantry", uselist=False)
