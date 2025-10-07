"""
Recipe Pantry API - Main Application Module

This module implements the FastAPI application for a recipe management system
with user authentication, recipe CRUD operations, and pantry tracking features.
It includes endpoints for user management, recipe creation/sharing, and matching
recipes based on available pantry ingredients.
"""

import os
from typing import List, Optional

from fastapi import APIRouter, Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import MetaData, Table, inspect, select, text
from sqlalchemy import or_ as db_or
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from src import models, schemas
from src.auth import create_access_token, decode_token
from src.auth_utils import hash_password, verify_password
from src.database import engine, get_db

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Recipe Pantry API - Week 3",
    description="Complete recipe management system with pantry tracking",
    version="0.3.0",
    openapi_tags=[
        {"name": "Auth", "description": "Authentication endpoints - Login and signup"},
        {"name": "User Profile", "description": "Manage your own profile"},
        {"name": "User - Recipes", "description": "Recipe management - Create, view, and manage " "your own recipes"},
        {"name": "User - Pantry", "description": "Manage your pantry ingredients"},
        {"name": "User - Database", "description": "View database structure (table names)"},
        {"name": "Admin - Users", "description": "Admin only - Manage all users"},
        {"name": "Admin - Recipes", "description": "Admin only - View and manage any recipe by ID"},
        {"name": "Admin - Database", "description": "Admin only - View actual table data"},
        {"name": "System", "description": "System endpoints - Health checks and info"},
    ],
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "null", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security scheme for Swagger
security = HTTPBearer()


# ===== WEEK 1 HELPER FUNCTIONS (unchanged) =====


def check_email_exists(email: str, db: Session) -> bool:
    """
    Checks if email is already in database.
    """
    user_with_email = (
        db.query(models.User)
        .filter(
            models.User.email == email,
        )
        .first()
    )
    return user_with_email is not None


def check_username_exists(username: str, db: Session) -> bool:
    """
    Checks if username is already taken.
    """
    user_with_username = (
        db.query(models.User)
        .filter(
            models.User.username == username,
        )
        .first()
    )
    return user_with_username is not None


# Note: create_user_in_database removed - use
# create_user_with_hashed_password instead


def find_user_by_id(user_id: int, db: Session) -> Optional[models.User]:
    """
    Finds a user by their ID number.
    """
    found_user = (
        db.query(models.User)
        .filter(
            models.User.id == user_id,
        )
        .first()
    )
    return found_user


def apply_user_updates(user: models.User, updates: dict, db: Session) -> models.User:
    """
    Updates user fields with new values.
    """
    # Update each field that was provided
    for field_name, new_value in updates.items():
        setattr(user, field_name, new_value)

    # Save changes to database
    db.commit()

    # Get updated user data
    db.refresh(user)

    return user


def remove_user_from_database(user: models.User, db: Session) -> None:
    """
    Deletes a user from the database.
    """
    # Mark user for deletion
    db.delete(user)
    # Actually delete from database
    db.commit()


# ===== WEEK 2 NEW HELPER FUNCTIONS =====


def find_user_by_email(email: str, db: Session) -> Optional[models.User]:
    """
    Finds a user by their email address.
    """
    found_user = (
        db.query(models.User)
        .filter(
            models.User.email == email,
        )
        .first()
    )
    return found_user


def create_user_with_hashed_password(user_data: schemas.UserCreate, db: Session) -> models.User:
    """
    Creates new user with properly hashed password.
    """
    # Create new user record with hashed password
    new_user_record = models.User(
        email=user_data.email,
        username=user_data.username,
        password_hash=hash_password(user_data.password),
    )
    # Add to database session (like adding to cart)
    db.add(new_user_record)
    # Save to database (like checkout)
    db.commit()
    # Get the generated ID back
    db.refresh(new_user_record)
    return new_user_record


def create_user_token(user: models.User) -> dict:
    """
    Creates a JWT token containing user information.
    """
    # Prepare data to include in token
    token_data = {"sub": str(user.id), "email": user.email}
    # Generate the actual token
    access_token = create_access_token(token_data)
    # Return token in standard format
    return {"access_token": access_token, "token_type": "bearer"}


def extract_user_id_from_token(token: str) -> int:
    """
    Decodes JWT token and extracts user ID.
    """
    # Decode the token (will raise exception if invalid)
    payload = decode_token(token)
    # Get user ID from payload
    user_id_string = payload.get("sub")
    # Check if user ID exists in token
    if not user_id_string:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate user",
        )
    # Convert to integer and return
    return int(user_id_string)


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)
) -> models.User:
    """
    Get current user from JWT token. Extracts token from
    Authorization header and validates it.
    """
    # Step 1: Get token from Authorization header
    token = credentials.credentials
    # Step 2: Extract user ID from token
    user_id = extract_user_id_from_token(token)
    # Step 3: Find user in database (reusing Week 1 function)
    user = find_user_by_id(user_id, db)
    # Step 4: Check if user exists
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    # Step 5: Return the user object
    return user


def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(
        security,
    ),
    db: Session = Depends(get_db),
) -> Optional[models.User]:
    """
    Get current user if authenticated, None otherwise. Useful for
    endpoints that behave differently for authenticated users.
    """
    # Step 1: Check if credentials were provided
    if not credentials:
        return None
    # Step 2: Try to get user, return None if any error
    try:
        return get_current_user(credentials, db)
    except HTTPException:
        return None


def check_user_permission(current_user_id: int, target_user_id: int) -> None:
    """
    Checks if current user has permission to modify target user.
    """
    if current_user_id != target_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only modify your own account",
        )


# ===== AUTHENTICATION ROUTES =====

auth_router = APIRouter(prefix="/auth", tags=["Auth"])


@auth_router.post("/signup", response_model=schemas.User, status_code=201)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """
    Creates a new user account:
    - Email must be unique
    - Password will be hashed before storage
    - Returns user info (no token on signup)
    """
    try:
        # Validate email format
        if "@" not in user.email or "." not in user.email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid email format. Please provide a valid email " "address.",
            )

        # Validate password strength
        if len(user.password) < 6:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must be at least 6 characters long",
            )

        # Step 1: Check if email already exists
        if check_email_exists(user.email, db):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Email '{user.email}' is already registered. Please "
                f"use a different email or login instead.",
            )

        # Step 2: Check if username already exists
        if check_username_exists(user.username, db):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Username '{user.username}' is already taken. Please " f"choose a different username.",
            )

        # Step 3: Create user with hashed password
        new_user = create_user_with_hashed_password(user, db)

        # Step 4: Create row in user_pantry immediately
        pantry = models.UserPantry(user_id=new_user.id, ingredients_json=[])
        db.add(pantry)
        db.commit()

        # Step 4: Return the created user
        return new_user
    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        if "email" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email address is already registered",
            )
        if "username" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username is already taken",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {str(e.orig)}",
        )
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Registration failed due to a database error. Please try " "again.",
        )


@auth_router.post("/login", response_model=schemas.Token)
def login(credentials: schemas.LoginRequest, db: Session = Depends(get_db)):
    """
    Login with email and password. Returns a JWT token for authentication.
    """
    try:
        # Validate email format
        if not credentials.email or not credentials.password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email and password are required",
            )

        # Step 1: Find user by email
        user = find_user_by_email(credentials.email, db)

        # Step 2: Check if user exists
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password. Please check your " "credentials and try again.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Step 3: Verify password is correct
        if not verify_password(credentials.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password. Please check your " "credentials and try again.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Step 4: Create and return JWT token
        token_response = create_user_token(user)
        return token_response
    except HTTPException:
        raise
    except SQLAlchemyError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Login failed due to a database error. Please try again " "later.",
        )


@auth_router.post(
    "/signup-admin",
    response_model=schemas.User,
    status_code=201,
)
def signup_admin(
    user: schemas.UserCreate,
    admin_secret: str = Query(
        ...,
        description="Secret key required to create admin users",
    ),
    db: Session = Depends(get_db),
):
    """
    Create an admin user - requires secret key.

    **Security:**
    - Secret required prevents unauthorized admin creation
    - Works universally on any PostgreSQL setup
    - No database-level permissions needed

    **Usage:**
    - Set ADMIN_SECRET in your .env file
    - Pass the secret as query parameter
    - User will be created with role='admin'
    """
    # Get secret from environment (or use default for demo)
    expected_secret = os.getenv("ADMIN_SECRET")
    if not expected_secret:
        raise ValueError("ADMIN_SECRET must be set in environment")

    if admin_secret != expected_secret:
        raise HTTPException(
            status_code=403,
            detail="Invalid admin secret. Check your ADMIN_SECRET " "environment variable.",
        )

    # Check if email already exists
    if check_email_exists(user.email, db):
        raise HTTPException(409, "Email already registered")

    # Check if username already exists
    if check_username_exists(user.username, db):
        raise HTTPException(409, "Username already taken")

    # Create admin user
    new_user_record = models.User(
        email=user.email,
        username=user.username,
        password_hash=hash_password(user.password),
        role="admin",  # Force admin role
    )

    db.add(new_user_record)
    db.commit()
    db.refresh(new_user_record)

    # Create pantry for admin user too
    pantry = models.UserPantry(user_id=new_user_record.id, ingredients_json=[])
    db.add(pantry)
    db.commit()

    return new_user_record


def require_admin(current_user: models.User = Depends(get_current_user)):
    """
    Dependency that requires the current user to be an admin.
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return current_user


# ===== WEEK 3: RECIPE HELPERS =====


def check_recipe_ownership(recipe_id: int, user_id: int, db: Session) -> bool:
    """
    Checks if user owns the specified recipe.
    Used for update/delete permissions.
    """
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
    """
    Finds a recipe by ID.
    Returns None if not found.
    """
    return (
        db.query(models.Recipe)
        .filter(
            models.Recipe.id == recipe_id,
        )
        .first()
    )


def create_recipe_in_database(recipe_data: schemas.RecipeCreate, user_id: int, db: Session) -> models.Recipe:
    """
    Creates new recipe and saves to database.
    Normalizes ingredients to lowercase for consistent matching.
    """
    # Normalize ingredients to lowercase
    normalized_ingredients = []
    for ingredient in recipe_data.ingredients_json:
        normalized_ingredients.append(ingredient.lower().strip())

    db_recipe = models.Recipe(
        user_id=user_id,
        title=recipe_data.title,
        ingredients_json=normalized_ingredients,
        instructions=recipe_data.instructions,
        prep_minutes=recipe_data.prep_minutes,
        is_public=recipe_data.is_public,
    )
    db.add(db_recipe)
    db.commit()
    db.refresh(db_recipe)
    return db_recipe


def update_recipe_in_database(recipe: models.Recipe, updates: dict, db: Session) -> models.Recipe:
    """
    Updates recipe fields with new values.
    Normalizes ingredients if being updated.
    """
    # If updating ingredients, normalize them
    if "ingredients_json" in updates:
        normalized_list = []
        for ing in updates["ingredients_json"]:
            normalized_list.append(ing.lower().strip())
        updates["ingredients_json"] = normalized_list

    for field, value in updates.items():
        setattr(recipe, field, value)

    db.commit()
    db.refresh(recipe)
    return recipe


def delete_recipe_from_database(recipe: models.Recipe, db: Session) -> None:
    """
    Deletes a recipe from the database.
    """
    db.delete(recipe)
    db.commit()


def get_visible_recipes(
    current_user: Optional[models.User], db: Session, skip: int = 0, limit: int = 100
) -> List[models.Recipe]:
    """
    Gets recipes visible to the current user:
    - All own recipes (public and private)
    - Other users' public recipes only
    """
    if current_user:
        # User logged in: see own + others' public
        return (
            db.query(models.Recipe)
            .filter(
                db_or(
                    models.Recipe.user_id == current_user.id,
                    models.Recipe.is_public == True,
                ),
            )
            .offset(skip)
            .limit(limit)
            .all()
        )
    # Not logged in: only public recipes
    return (
        db.query(models.Recipe)
        .filter(
            models.Recipe.is_public == True,
        )
        .offset(skip)
        .limit(limit)
        .all()
    )


# ===== WEEK 3: PANTRY HELPERS =====


def find_or_create_pantry(user_id: int, db: Session) -> models.UserPantry:
    """Find or create user's pantry with proper error handling"""
    pantry = (
        db.query(models.UserPantry)
        .filter(
            models.UserPantry.user_id == user_id,
        )
        .first()
    )

    if not pantry:
        try:
            pantry = models.UserPantry(
                user_id=user_id,
                ingredients_json=[],
                # Do NOT set id - let database handle it
            )
            db.add(pantry)
            db.commit()
            db.refresh(pantry)
        except IntegrityError:
            db.rollback()
            # Try to fetch again in case of race condition
            pantry = (
                db.query(models.UserPantry)
                .filter(
                    models.UserPantry.user_id == user_id,
                )
                .first()
            )
            if not pantry:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to create pantry. Please try again.",
                )

    return pantry


def update_pantry_ingredients(pantry: models.UserPantry, ingredients: List[str], db: Session) -> models.UserPantry:
    """
    Updates pantry with new ingredient list.
    Normalizes ingredients to lowercase.
    """
    # Normalize and deduplicate
    temp_list = []
    for ingredient in ingredients:
        if ingredient.strip():
            temp_list.append(ingredient.lower().strip())
    normalized = list(set(temp_list))

    pantry.ingredients_json = sorted(normalized)
    db.commit()
    db.refresh(pantry)
    return pantry


app.include_router(auth_router)

# ===== DATABASE VIEWER ENDPOINTS =====

db_router = APIRouter(prefix="/db")


@db_router.get("/tables", tags=["User - Database"])
def get_database_tables(
    current_user: models.User = Depends(get_current_user),  # pylint: disable=unused-argument
    db: Session = Depends(get_db),  # pylint: disable=unused-argument
):
    """
    Get list of all tables in the database.
    Available to all authenticated users - shows table names only, not data.
    """
    try:
        inspector = inspect(engine)
        table_names = inspector.get_table_names()
        return {"tables": table_names}
    except SQLAlchemyError as e:
        raise HTTPException(500, f"Database error: {str(e)}")


@db_router.get("/tables/{table_name}", tags=["Admin - Database"])
def get_table_data(
    table_name: str,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
    db: Session = Depends(get_db),
):
    """
    Get all data from a specific table.
    Admin access required - returns actual row data.
    """
    try:
        # Verify table exists
        inspector = inspect(engine)
        table_names = inspector.get_table_names()

        if table_name not in table_names:
            raise HTTPException(404, f"Table '{table_name}' not found")

        # Get column information
        columns_info = inspector.get_columns(table_name)
        column_names = []
        for col in columns_info:
            column_names.append(col["name"])

        # Get all rows - Parameterization instead text() to avoid SQL injection
        metadata = MetaData()
        table = Table(table_name, metadata, autoload_with=engine)
        result = db.execute(select(table))
        rows = result.fetchall()

        # Convert rows to dictionaries
        row_dicts = []
        for row in rows:
            row_dict = {}
            for i, col_name in enumerate(column_names):
                row_dict[col_name] = row[i]
            row_dicts.append(row_dict)

        return {"table_name": table_name, "columns": column_names, "rows": row_dicts}

    except SQLAlchemyError as e:
        raise HTTPException(500, f"Database error: {str(e)}")


app.include_router(db_router)


# ===== ROOT ENDPOINT =====


@app.get("/", tags=["System"])
def root():
    """
    Root endpoint that provides API information and links to documentation.
    Returns basic API metadata including version and available endpoints.
    """
    return {"message": "Recipe Pantry API", "version": "0.3.0", "docs": "/docs", "health": "/health"}


# ===== USER SELF-MANAGEMENT ENDPOINTS (/me) =====


# GET CURRENT USER - View own profile
@app.get("/me", response_model=schemas.User, tags=["User Profile"])
def get_current_user_profile(current_user: models.User = Depends(get_current_user)):
    """
    Get the current user's profile.
    Any authenticated user can view their own profile.
    """
    return current_user


# UPDATE CURRENT USER - Update own profile
@app.put("/me", response_model=schemas.User, tags=["User Profile"])
def update_current_user_profile(
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Update the current user's profile.
    Users can only update their own profile.
    """
    # Get only the fields that were sent
    update_data = user_update.model_dump(exclude_unset=True)
    # Apply the updates (reusing Week 1 function)
    updated_user = apply_user_updates(current_user, update_data, db)
    return updated_user


# DELETE CURRENT USER - Delete own account
@app.delete("/me", tags=["User Profile"])
def delete_current_user_account(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Delete the current user's account.
    Users can only delete their own account.
    Admins cannot delete their own account for safety.
    """
    # Prevent admins from deleting themselves
    if current_user.role == "admin":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin accounts cannot be self-deleted for safety. " "Contact another admin.",
        )
    # Delete the user (reusing Week 1 function)
    remove_user_from_database(current_user, db)
    return {"message": "Your account has been deleted"}


# ===== USER CRUD ENDPOINTS (Admin Only) =====

# CREATE USER - Disabled in favor of /auth/signup
# The old endpoint is commented out to avoid confusion


# GET ALL USERS - Admin only
@app.get("/users", response_model=List[schemas.User], tags=["Admin - Users"])
def get_users(
    skip: int = 0,
    limit: int = 100,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
    db: Session = Depends(get_db),
):
    """
    Get a paginated list of all users in the system.
    Admin access required. Supports pagination via skip and limit parameters.
    """
    # Only admins can see all users
    return db.query(models.User).offset(skip).limit(limit).all()


# GET USER BY ID - Admin only
@app.get(
    "/users/{user_id}",
    response_model=schemas.User,
    tags=["Admin - Users"],
)
def get_user(user_id: int, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Gets one user by their ID.
    Admin access only.
    """
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


# UPDATE USER - Admin only
@app.put(
    "/users/{user_id}",
    response_model=schemas.User,
    tags=["Admin - Users"],
)
def update_user(
    user_id: int,
    user_update: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Update a user's information by their ID.
    Admin access required. Validates email/username uniqueness.
    """
    try:
        # Step 1: Check admin permission
        if current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Admin access required. Only administrators can " "update user accounts.",
            )

        # Step 2: Find the user to update
        user = find_user_by_id(user_id, db)

        # Step 3: Check if user exists
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} not found",
            )

        # Step 4: Get only the fields that were sent
        update_data = user_update.model_dump(exclude_unset=True)

        # Check if updating email to one that already exists
        if "email" in update_data and update_data["email"] != user.email:
            if check_email_exists(update_data["email"], db):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Email '{update_data['email']}' is already " f"registered to another user",
                )

        # Check if updating username to one that already exists
        if "username" in update_data and update_data["username"] != user.username:
            if check_username_exists(update_data["username"], db):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Username '{update_data['username']}' is already" f" taken",
                )

        # Step 5: Apply the updates
        updated_user = apply_user_updates(user, update_data, db)

        # Step 6: Return updated user
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
            detail=f"Database constraint violation: {str(e.orig)}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error updating user: {str(e)}",
        )


# DELETE USER - Admin only
@app.delete("/users/{user_id}", tags=["Admin - Users"])
def delete_user(user_id: int, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Delete a user account by their ID.
    Admin access required. Cannot delete admin accounts for safety.
    """
    # Step 1: Check admin permission
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    # Step 2: Prevent admin from deleting themselves
    if current_user.id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own admin account",
        )
    # Step 3: Find the user to delete (reusing Week 1 function)
    user = find_user_by_id(user_id, db)
    # Step 4: Check if user exists
    if not user:
        raise HTTPException(404, f"No user with ID {user_id}")
    # Step 5: Prevent deletion of any admin account
    if user.role == "admin":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Admin accounts cannot be deleted through the API for " "safety",
        )
    # Step 6: Delete the user (reusing Week 1 function)
    remove_user_from_database(user, db)
    # Step 7: Return success message
    return {"message": f"User {user_id} was deleted"}


# HEALTH CHECK
@app.get("/health", tags=["System"])
def health_check(db: Session = Depends(get_db)):
    """
    Health check endpoint to verify API and database connectivity.
    Returns health status including database connection state.
    """
    try:
        db.execute(text("SELECT 1"))
        return {"status": "healthy", "database": "connected"}
    except (SQLAlchemyError, ConnectionError):
        return {"status": "unhealthy", "database": "disconnected"}


# ===== WEEK 3: RECIPE CRUD ENDPOINTS =====


# CREATE RECIPE
@app.post(
    "/me/recipes",
    response_model=schemas.Recipe,
    status_code=status.HTTP_201_CREATED,
    tags=["User - Recipes"],
)
def create_recipe(
    recipe: schemas.RecipeCreate, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)
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
                f"Please choose a different title or update the "
                f"existing recipe.",
            )

        new_recipe = create_recipe_in_database(recipe, current_user.id, db)
        return new_recipe
    except HTTPException:
        raise
    except IntegrityError as e:
        db.rollback()
        if "unique" in str(e.orig).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Recipe '{recipe.title}' already exists for this user",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Database constraint violation: {str(e.orig)}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error occurred: {str(e)}",
        )


# GET ALL RECIPES - Admin only
@app.get(
    "/recipes",
    response_model=List[schemas.Recipe],
    tags=["Admin - Recipes"],
)
def get_recipes(
    skip: int = 0,
    limit: int = 100,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
    db: Session = Depends(get_db),
):
    """
    Get all recipes in the database.
    Admin access only - returns all recipes (public and private).
    """
    recipes = db.query(models.Recipe).offset(skip).limit(limit).all()
    return recipes


# GET USER'S OWN RECIPES
@app.get(
    "/me/recipes",
    response_model=List[schemas.Recipe],
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
        .filter(
            models.Recipe.user_id == current_user.id,
        )
        .offset(skip)
        .limit(limit)
        .all()
    )
    return recipes


# GET AVAILABLE RECIPES (Must be before /{recipe_id} route!)
@app.get(
    "/me/recipes/available",
    response_model=schemas.RecipeMatchResponse,
    tags=["User - Recipes"],
)
def get_available_recipes_based_on_pantry(
    threshold: float = 0.5, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """
    Get recipes user can make based on pantry contents.
    - Requires at least 1 matching ingredient (this is matching,
    not a cookbook!)
    - Returns recipes where user has >= threshold% of ingredients
    - Default threshold is 50%
    - Shows own recipes + others' public recipes
    """
    # Validate threshold
    if not 0 <= threshold <= 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Threshold must be between 0 and 1",
        )

    # Get user's pantry
    pantry = find_or_create_pantry(current_user.id, db)
    pantry_ingredients = set(pantry.ingredients_json)

    # Get all visible recipes
    recipes = get_visible_recipes(current_user, db)

    # Calculate matches
    matches = []
    for recipe in recipes:
        recipe_ingredients = set(recipe.ingredients_json)

        if not recipe_ingredients:  # Skip recipes with no ingredients
            continue

        # Calculate match details
        available_ingredients = pantry_ingredients.intersection(
            recipe_ingredients,
        )
        missing_ingredients = recipe_ingredients - pantry_ingredients
        match_percentage = len(available_ingredients) / len(recipe_ingredients)

        # Must have at least 1 ingredient AND meet threshold percentage
        has_minimum_match = len(available_ingredients) >= 1
        meets_threshold = match_percentage >= threshold

        # Check if meets requirements
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
                available_ingredients=sorted(list(available_ingredients)),
                missing_ingredients=sorted(list(missing_ingredients)),
                is_own_recipe=is_own,
            )
            matches.append(match)

    # Sort by match percentage (descending)
    matches.sort(
        key=lambda x: x.ingredients_available / x.ingredients_total,
        reverse=True,
    )

    return schemas.RecipeMatchResponse(
        recipes=matches,
        threshold=threshold,
        user_pantry=sorted(pantry.ingredients_json),
    )


# GET SINGLE RECIPE - Admin only
@app.get(
    "/recipes/{recipe_id}",
    response_model=schemas.Recipe,
    tags=["Admin - Recipes"],
)
def get_recipe(
    recipe_id: int,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
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


# UPDATE OWN RECIPE BY ID
@app.put(
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
                detail="You don't have permission to update this recipe. You " "can only update your own recipes.",
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
                    detail=f"You already have another recipe c"
                    f"alled '{update_data['title']}'. Please choose a "
                    f"different title.",
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
            detail=f"Update failed - constraint violation: {str(e.orig)}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error during update: {str(e)}",
        )


# UPDATE RECIPE - Admin only
@app.put(
    "/recipes/{recipe_id}",
    response_model=schemas.Recipe,
    tags=["Admin - Recipes"],
)
def update_recipe(
    recipe_id: int,
    recipe_update: schemas.RecipeUpdate,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
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

        # Check if changing title to one that already exists for the recipe
        # owner
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
                    detail=f"User already has another recipe called '"
                    f"{update_data['title']}'. Cannot create "
                    f"duplicate.",
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
            detail=f"Update failed - database constraint viol" f"ation: {str(e.orig)}",
        )
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error during recipe update: {str(e)}",
        )


# DELETE OWN RECIPE BY ID
@app.delete(
    "/me/recipes/{recipe_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["User - Recipes"],
)
def delete_my_recipe(
    recipe_id: int, current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """
    Delete your own recipe.
    - Only the recipe owner can delete
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
                detail="You don't have permission to delete this recipe. You " "can only delete your own recipes.",
            )

        delete_recipe_from_database(recipe, db)
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete recipe: {str(e)}",
        )


# DELETE RECIPE - Admin only
@app.delete(
    "/recipes/{recipe_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Admin - Recipes"],
)
def delete_recipe(
    recipe_id: int,
    admin: models.User = Depends(require_admin),  # pylint: disable=unused-argument
    db: Session = Depends(get_db),
):
    """
    Delete any recipe.
    Admin access only.
    """
    try:
        recipe = find_recipe_by_id(recipe_id, db)

        if not recipe:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Recipe with ID {recipe_id} not found. Please check " f"the recipe ID and try again.",
            )

        # Note: Admin deleting recipe - no owner info needed for 204 response
        delete_recipe_from_database(recipe, db)

        # Note: 204 No Content doesn't return a body, so this detail won't
        # be shown
        # But it's here for documentation purposes
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete recipe: {str(e)}",
        )


# ===== WEEK 3: PANTRY ENDPOINTS =====


# GET PANTRY
@app.get("/me/pantry", response_model=schemas.Pantry, tags=["User - Pantry"])
def get_pantry(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Get user's pantry contents.
    - Creates empty pantry if doesn't exist
    """
    pantry = find_or_create_pantry(current_user.id, db)
    return pantry


# UPDATE PANTRY
@app.put("/me/pantry", response_model=schemas.Pantry, tags=["User - Pantry"])
def update_pantry(
    pantry_update: schemas.PantryUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Update pantry contents.
    - Replaces entire ingredient list
    - Ingredients are normalized and deduplicated
    """
    try:
        # Validate ingredients list
        if not isinstance(pantry_update.ingredients_json, list):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ingredients must be provided as a list",
            )

        # Check for invalid ingredient types
        for ingredient in pantry_update.ingredients_json:
            if not isinstance(ingredient, str):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"All ingredients must be strings. Found: " f"{type(ingredient).__name__}",
                )
            if not ingredient.strip():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Ingredients cannot be empty strings",
                )

        pantry = find_or_create_pantry(current_user.id, db)
        updated_pantry = update_pantry_ingredients(
            pantry,
            pantry_update.ingredients_json,
            db,
        )
        return updated_pantry
    except HTTPException:
        raise
    except SQLAlchemyError as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database error updating pantry: {str(e)}",
        )
