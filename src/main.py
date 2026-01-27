"""
Recipe Pantry API - Main Application Module

This is the entry point for the FastAPI application.
It sets up the app configuration, middleware, and includes all routers.
"""

import os

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from src import models
from src.database import engine, get_db
from src.routers import ai, auth, database, pantry, recipes, users


def validate_required_config():
    """
    Checks that all required environment variables exist. Defensive programming
    to avoid unexpected errors from missing variables.
    """
    required_vars = ["DATABASE_URL", "JWT_SECRET_KEY", "ADMIN_SECRET"]

    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)

    if missing_vars:
        raise ValueError(f"Missing environment variables: {missing_vars}")


# Startup tasks run at module level because FastAPI doesn't use main() or __main__,
# and @app.on_event("startup") was deprecated in FastAPI version 0.104.0
validate_required_config()
models.Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Recipe Pantry API",
    description="Complete recipe management system with pantry tracking",
    version="0.2.0",
    openapi_tags=[
        {
            "name": "Auth",
            "description": "Authentication endpoints - Login and signup",
        },
        {
            "name": "User Profile",
            "description": "Manage your own profile",
        },
        {
            "name": "User - Recipes",
            "description": "Recipe management - Create, view, and manage your own recipes",
        },
        {
            "name": "User - Pantry",
            "description": "Manage your pantry ingredients",
        },
        {
            "name": "User - Database",
            "description": "View database structure (table names)",
        },
        {
            "name": "Admin - Users",
            "description": "Admin only - Manage all users",
        },
        {
            "name": "Admin - Recipes",
            "description": "Admin only - View and manage any recipe by ID",
        },
        {
            "name": "Admin - Database",
            "description": "Admin only - View actual table data",
        },
        {
            "name": "System",
            "description": "System endpoints - Health checks and info",
        },
    ],
)

# CORS configuration
CORS_ORIGINS = os.getenv(
    "CORS_ORIGINS",
    "http://localhost:3000",
).split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(recipes.router)
app.include_router(pantry.router)
app.include_router(database.router)
app.include_router(ai.router)


@app.get("/docs-overview", include_in_schema=False)
def docs_overview():
    """Custom API overview dashboard showing all read-only endpoints."""
    return FileResponse("static/docs_overview.html")


# Root endpoint
@app.get("/", tags=["System"])
def root():
    """
    Root endpoint that provides API information and links to documentation.
    Returns basic API metadata including version and available endpoints.
    """
    return {
        "message": "Recipe Pantry API",
        "version": "0.2.0",
        "docs": "/docs",
        "health": "/health",
    }


# Health check endpoint
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


# Mount static files last to avoid shadowing API routes
app.mount("/static", StaticFiles(directory="static"), name="static")
