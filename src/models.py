"""
Database Models - User Table Structure

Defines the User model for the database, according to the database schema.
Each User represents someone who can store recipes in the recipe pantry system.
"""

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from src.database import Base


class User(Base):  # pylint: disable=too-few-public-methods
    """
    User model for storing user account information.

    Represents a user in the recipe pantry system with email, username,
    password, and automatic timestamp tracking for when accounts are
    created and updated.
    """

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, nullable=False)
    username = Column(String(100), unique=True, nullable=False)
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

    __table_args__ = (
        CheckConstraint(
            "role IN ('admin', 'user')",
            name="check_role_values",
        ),
    )

    # Relationship to Recipe
    recipes = relationship(
        "Recipe",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    # Relationship to UserPantry
    user_pantry = relationship(
        "UserPantry",
        back_populates="user",
        cascade="all, delete-orphan",
    )


class Ingredient(Base):
    """
    Ingredient model for storing ingredient information.

    Represents an ingredient in the recipe pantry system with name
    and synonyms for flexible ingredient matching. Each ingredient
    name must be unique in the system.
    """

    __tablename__ = "ingredients"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False, unique=True)  # Must be unique
    synonyms = Column(
        JSONB, nullable=False, server_default="[]"
    )  # Recipe matching

    # Relationship to UserPantry
    user_pantry = relationship(
        "UserPantry",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )

    # Relationship to RecipeIngredient
    recipe_ingredients = relationship(
        "RecipeIngredient",
        back_populates="ingredient",
        cascade="all, delete-orphan",
    )


class Recipe(Base):
    """
    Recipe model for storing cooking instructions and ingredients.
    'ingredients_json' is ORM-managed UX summary field
    """

    __tablename__ = "recipes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    title = Column(String(255), nullable=False)
    # 'ingredients_json' is ORM-managed UX summary field
    ingredients_json = Column(JSONB, nullable=False, server_default="[]")
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
    user = relationship(
        "User",
        back_populates="recipes",
    )

    # Relationship to RecipeIngredient
    recipe_ingredients = relationship(
        "RecipeIngredient",
        back_populates="recipe",
        cascade="all, delete-orphan",
    )

    __table_args__ = (
        UniqueConstraint(
            user_id,
            title,
            name="unique_recipe_title_per_user",
        ),
    )


class RecipeIngredient(Base):
    """
    RecipeIngredient model for linking recipes with ingredients.

    Represents a mapping between recipes and ingredients with a primary
    key, foreign key references to both recipes and ingredients
    tables, and denormalized names for debugging/DX. Enforces unique
    recipe-ingredient combinations through a constraint.
    Both 'recipe_name' and 'ingredient_name' are ORM-managed DX fields.
    """

    __tablename__ = "recipe_ingredients"

    id = Column(Integer, primary_key=True)
    recipe_id = Column(
        Integer,
        ForeignKey("recipes.id", ondelete="CASCADE"),
        nullable=False,
    )
    ingredient_id = Column(
        Integer,
        ForeignKey("ingredients.id", ondelete="CASCADE"),
        nullable=False,
    )
    recipe_name = Column(  # ORM-managed DX field
        String(255),
        nullable=False,
    )
    ingredient_name = Column(  # ORM-managed DX field
        String(100),
        nullable=False,
    )

    # Relationship back to Recipe
    recipe = relationship(
        "Recipe",
        back_populates="recipe_ingredients",
    )

    # Relationship back to Ingredient
    ingredient = relationship(
        "Ingredient",
        back_populates="recipe_ingredients",
    )

    __table_args__ = (
        UniqueConstraint(
            recipe_id,
            ingredient_id,
            name="unique_recipe_ingredient",
        ),
    )


class UserPantry(Base):
    """
    UserPantry model for tracking what ingredients users have
    available.
    'ingredient_name' is ORM-managed UX summary field
    """

    __tablename__ = "user_pantry"

    id = Column(Integer, primary_key=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    ingredient_id = Column(
        Integer,
        ForeignKey("ingredients.id", ondelete="CASCADE"),
        nullable=False,
    )
    ingredient_name = Column(  # ORM-managed UX summary field
        String(100),
        nullable=False,
    )
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),  # pylint: disable=not-callable
    )

    # Relationship back to User
    user = relationship(
        "User",
        back_populates="user_pantry",
    )

    # Relationship back to Ingredient
    ingredient = relationship(
        "Ingredient",
        back_populates="user_pantry",
    )

    __table_args__ = (
        UniqueConstraint(
            user_id,
            ingredient_id,
            name="unique_user_ingredient",
        ),
    )
