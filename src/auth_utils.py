"""
Authentication Utilities

Provides password hashing functions using bcrypt for secure password storage.
"""

from passlib.context import CryptContext

# Create password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a plain password using bcrypt.
    Returns a hash string that includes the salt.
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against a hash.
    Returns True if password matches, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)
