"""
Database Setup Module

Sets up the backend connection between PostgreSQL and FastAPI. Creates the
SQLAlchemy engine, database session and provides get_db() to FastAPI to manage
database sessions for each API request.
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL not found in .env file")

engine = create_engine(DATABASE_URL, echo=False)  # echo=True shows SQL
SessionLocal = sessionmaker(
    autocommit=False,  # Automatically commits changes to database
    autoflush=False,  # Sends pending changes from memory to DB without commit
    bind=engine,  # Connect all sessions to **this** DB
)
Base = declarative_base()  # Base class for all models (User, Recipe, etc.)


def get_db():
    """
    Provides database session for each request.
    """
    db = SessionLocal()  # Step 1: Create a new database session
    try:
        yield db  # Step 2: Give the session to the endpoint
    finally:
        db.close()  # Step 3: Always close the session when done
