"""
Authentication endpoints - Login and signup.
"""

import os

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from src import schemas
from src.auth_utils import verify_password
from src.database import get_db
from src.helpers.user_helpers import (
    check_email_exists,
    check_username_exists,
    create_user_token,
    create_user_with_hashed_password,
    find_user_by_email,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/signup", response_model=schemas.User, status_code=201)
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
                detail="Invalid email format. Please provide a valid email address.",
            )

        # Validate password strength
        if len(user.password) < 6:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password must be at least 6 characters long",
            )

        # Check if email already exists
        if check_email_exists(user.email, db):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Email '{user.email}' is already registered. Please use a different email or login instead.",
            )

        # Check if username already exists
        if check_username_exists(user.username, db):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Username '{user.username}' is already taken. Please choose a different username.",
            )

        # Create user with hashed password
        new_user = create_user_with_hashed_password(user, db)
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
            detail=f"Registration failed: {e.orig!s}",
        )
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Registration failed due to a database error. Please try again.",
        )


@router.post("/login", response_model=schemas.Token)
def login(credentials: schemas.LoginRequest, db: Session = Depends(get_db)):
    """
    Login with email and password. Returns a JWT token for authentication.
    """
    try:
        # Validate input
        if not credentials.email or not credentials.password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email and password are required",
            )

        # Find user by email
        user = find_user_by_email(credentials.email, db)

        # Check if user exists
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password. Please check your credentials and try again.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Verify password
        if not verify_password(credentials.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password. Please check your credentials and try again.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Create and return JWT token
        token_response = create_user_token(user)
        return token_response

    except HTTPException:
        raise
    except SQLAlchemyError:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Login failed due to a database error. Please try again later.",
        )


@router.post(
    "/signup-admin",
    response_model=schemas.User,
    status_code=201,
)
def signup_admin(
    admin_data: schemas.AdminUserCreate,
    db: Session = Depends(get_db),
):
    """
    Create an admin user - requires secret key in request body.
    Hidden from public API documentation for security.
    """
    # Get secret from environment
    expected_secret = os.getenv("ADMIN_SECRET")
    if not expected_secret:
        raise ValueError("ADMIN_SECRET must be set in environment")

    if admin_data.admin_secret != expected_secret:
        raise HTTPException(
            status_code=403,
            detail="Invalid admin secret. Check your ADMIN_SECRET environment variable.",
        )

    # Check if email already exists
    if check_email_exists(admin_data.email, db):
        raise HTTPException(409, "Email already registered")

    # Check if username already exists
    if check_username_exists(admin_data.username, db):
        raise HTTPException(409, "Username already taken")

    # Create admin user
    user_data = schemas.UserCreate(
        email=admin_data.email,
        username=admin_data.username,
        password=admin_data.password,
    )
    new_user_admin = create_user_with_hashed_password(
        user_data,
        db,
        role="admin",
    )
    return new_user_admin
