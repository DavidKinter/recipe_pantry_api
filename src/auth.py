"""
JWT Authentication Utilities

Provides JWT token creation and verification functions for secure
authentication.
"""

from datetime import UTC, datetime, timedelta
import os

from dotenv import load_dotenv
from fastapi import HTTPException, status
from jose import (  # type: ignore  # noqa: PGH003
    ExpiredSignatureError,
    JWTError,
    jwt,
)

load_dotenv()

# Configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
EXPIRE_DAYS = int(os.getenv("JWT_EXPIRATION_DAYS", "30"))

if not SECRET_KEY:
    raise ValueError("JWT_SECRET_KEY not found in environment variables")


def create_access_token(data: dict) -> str:
    """
    Creates a JWT token with the provided data.
    """
    # Copy data to avoid modifying original
    to_encode = data.copy()

    # Add expiration time (using timezone-aware datetime)
    expire = datetime.now(UTC) + timedelta(days=EXPIRE_DAYS)
    to_encode.update({"exp": expire})

    # Create token
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def decode_token_or_fail(token: str) -> dict:
    """
    Decode a JWT token with detailed error handling.
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except ExpiredSignatureError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e
