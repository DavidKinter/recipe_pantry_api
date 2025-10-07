"""
API Schemas - Data Validation Rules

Defines Pydantic models for validating data coming into and going out of the
API endpoints. These schemas ensure users provide the correct data format,
allowing FastAPI to return clean and consistent responses.
"""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# Week 1: User schemas only
class UserBase(BaseModel):
    """
    Base user fields shared by other user schemas.
    Contains email and username used in CREATE and UPDATE operations.
    """

    email: EmailStr
    username: str = Field(..., min_length=3, max_length=100)


class UserCreate(UserBase):
    """
    Schema for creating new user accounts.
    Includes password field required for sign-up.
    """

    password: str = Field(..., min_length=6)


class UserUpdate(BaseModel):
    """
    Schema for updating user information. All fields are optional,
    allowing users to decide whether they prefer to only update their
    email, their username, or both.
    """

    email: Optional[EmailStr] = None
    username: Optional[str] = Field(None, min_length=3, max_length=100)


class User(UserBase):  # pylint: disable=too-few-public-methods
    """
    Complete user information returned by the API. Includes all user data,
    plus id and timestamps. NEVER includes passwords or corresponding
    hashes to ensure security.
    """

    model_config = ConfigDict(from_attributes=True)

    id: int
    role: str = Field(default="user")
    created_at: datetime
    updated_at: datetime


class Token(BaseModel):
    """Schema for authentication tokens returned after successful login."""

    access_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    """Schema for user login credentials."""

    email: EmailStr
    password: str


# Week 3: Recipe schemas
class RecipeBase(BaseModel):
    """Base recipe fields shared by create and update."""

    title: str = Field(..., min_length=1, max_length=255)
    ingredients_json: List[str]
    instructions: str = Field(..., min_length=1)
    prep_minutes: Optional[int] = Field(None, ge=0)
    is_public: bool = False


class RecipeCreate(RecipeBase):
    """Schema for creating a new recipe."""


class RecipeUpdate(BaseModel):
    """Schema for updating a recipe. All fields optional."""

    title: Optional[str] = Field(None, min_length=1, max_length=255)
    ingredients_json: Optional[List[str]] = None
    instructions: Optional[str] = Field(None, min_length=1)
    prep_minutes: Optional[int] = Field(None, ge=0)
    is_public: Optional[bool] = None


class Recipe(RecipeBase):
    """Complete recipe returned by API."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime


# Week 3: Pantry schemas
class PantryUpdate(BaseModel):
    """Schema for updating pantry contents."""

    ingredients_json: List[str]


class Pantry(BaseModel):
    """Complete pantry information returned by API."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    ingredients_json: List[str]
    created_at: datetime
    updated_at: datetime


# Week 3: Recipe matching response
class RecipeMatch(BaseModel):
    """Recipe with matching information."""

    model_config = ConfigDict(from_attributes=True)

    title: str
    prep_minutes: Optional[int]
    instructions: str
    ingredients_json: List[str]
    ingredients_total: int
    ingredients_available: int
    ingredients_missing: int
    available_ingredients: List[str]
    missing_ingredients: List[str]
    is_own_recipe: bool  # Indicates if this is the user's recipe


class RecipeMatchResponse(BaseModel):
    """Response for recipe matching endpoint."""

    recipes: List[RecipeMatch]
    threshold: float
    user_pantry: List[str]
