# Recipe Pantry API

Week 3 Submission - Masterschool Bootcamp

## Project Status

This is my Week 3 checkpoint submission. Core API is complete and tested, deployment next week.

### What's Working
- FastAPI with 20+ endpoints
- PostgreSQL database (3 tables, proper relationships)
- JWT auth with bcrypt
- Full CRUD for users, recipes, pantry
- Recipe matching algorithm
- 50 Postman tests
- Admin role system

### Still TODO
- Deploy to Render
- Split main.py (1449 lines is too much)
- Add refresh tokens if time

## Quick Start

Requirements: Python 3.12+, PostgreSQL 17 (using Homebrew on Mac)

```bash
# Clone and install
pip install -r requirements.txt

# Create database
psql -U your_user -c "CREATE DATABASE recipe_pantry_api_dev;"

# Configure .env (copy from .env.example)
DATABASE_URL=postgresql://your_user:your_password@localhost/recipe_pantry_api_dev
SECRET_KEY=your-secret-key-here
JWT_SECRET_KEY=your-jwt-secret-key-here
JWT_ALGORITHM=HS256
JWT_EXPIRATION_DAYS=30
ADMIN_SECRET=change_this_to_something_secure

# Run server
uvicorn src.main:app --reload
```

API docs: http://localhost:8000/docs

## Features

Recipe management where users can:
- Store recipes with ingredients (JSON)
- Track pantry items
- Find recipes based on available ingredients
- Public/private recipe sharing

Admin features:
- View all users/recipes
- Database inspection endpoints

## Database Schema

3 tables with CASCADE deletes:

**users**
- id, email (unique), username (unique), role (admin/user)
- password_hash, created_at, updated_at

**recipes**
- id, user_id (FK), title, ingredients_json, instructions
- prep_minutes, is_public, timestamps

**user_pantry**
- id, user_id (FK), ingredient, quantity, unit, timestamps

Load sample data: `psql $DATABASE_URL -f templates/recipe_pantry_api_dev.sql`

## Endpoints

Auth (`/auth/*`):
- POST /signup - register user
- POST /login - get JWT token
- POST /signup-admin - admin registration (needs ADMIN_SECRET)

User (`/me/*`):
- GET/PUT/DELETE /me - profile management
- GET /me/recipes - user's recipes
- GET /me/pantry - user's ingredients
- PUT /me/pantry - update pantry
- GET /me/recipes/available - matching based on pantry

Admin (`/users/*`, `/recipes/*`):
- GET /users - all users
- GET/PUT/DELETE /users/{id} - user management
- GET /recipes - all recipes (with filters)

System:
- GET / - welcome
- GET /health - status check

## Testing

Run full test suite:
1. Import `tests/Recipe_Pantry_API_Full_Test.postman_collection.json` in Postman
2. Run collection (creates/deletes test data automatically)
3. Clean admin user: `psql $DATABASE_URL -f tests/postman_cleanup_admin.sql`

50 tests covering all endpoints, edge cases, auth flows.

## Code Quality

Linted with ruff and sqlfluff (see docs/LINTING.md for details).

Known issue: main.py is 1449 lines. Should split into modules but everything works and is tested so leaving for now.

## Recipe Matching Logic

The `/me/recipes/available` endpoint calculates match percentage:
- Compares recipe ingredients with user pantry
- Returns recipes where you have X% of ingredients
- Default threshold: 50% (configurable via query param)

Example: Recipe needs [eggs, milk, flour]. You have [eggs, milk]. Match = 66%.

## Week 3 Requirements Checklist

- [x] FastAPI framework - full implementation
- [x] Project documented - recipe pantry with matching
- [x] Database schema - 3 tables with relationships
- [x] Local server - localhost:8000
- [x] PostgreSQL - recipe_pantry_api_dev database
- [x] GitHub repo - with .gitignore
- [x] .ENV file - all secrets configured
- [x] Server-DB connection - SQLAlchemy ORM
- [x] CRUD operations - all entities covered
- [x] JWT auth - 30-day tokens
- [x] /me endpoint - full user management
- [x] Password encryption - bcrypt hashing
- [x] Unique emails - enforced in DB and code
- [x] API testing - 50 Postman tests
- [x] Swagger docs - auto-generated
- [x] POC ready - fully functional

## Next Week

1. Deploy to Render
2. Refactor main.py into modules
3. Add any missing features from feedback

---
*Week 3 milestone ready for review*
