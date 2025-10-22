# Recipe Pantry API

MVP - Masterschool Bootcamp

## Project Status

✅ **Deployed and fully operational:** https://recipe-pantry-api.onrender.com

Try it:
- API Docs: https://recipe-pantry-api.onrender.com/docs
- Health Check: https://recipe-pantry-api.onrender.com/health

### What's Working
- FastAPI with 20+ endpoints
- PostgreSQL database (5 tables: users, recipes, ingredients, recipe_ingredients, user_pantry)
- 2080 professionally curated ingredients (FDA compliant, culturally sensitive)
- JWT auth with bcrypt password hashing
- Full CRUD for users, recipes, pantry
- Recipe matching algorithm with synonym support
- 156 test assertions across 127 requests with automated cleanup
- Admin role system

### Database Highlights
- Normalized 5-table structure with junction tables
- Unique ingredient names (no duplicates)
- Cultural sensitivity (proper diacriticals, offensive terms removed)
- Ingredient names follow FDA dairy product definitions (heavy cream vs light cream)
- Botanical accuracy prevents recipe errors (sweet potatoes ≠ yams)
- Denormalized fields for developer experience (debugging-friendly)

### Deployment
- Database and API fully deployed through Render's "Postgres" and "Web Service" services
- Deployed API: https://recipe-pantry-api.onrender.com

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

5-table normalized structure with CASCADE deletes:

**users**
- id, email (unique), username (unique), role (admin/user)
- password_hash, created_at, updated_at

**ingredients** (2080 pre-populated)
- id, name (unique), synonyms (JSONB array)
- Culturally sensitive, FDA compliant, botanically accurate

**recipes**
- id, user_id (FK), title (unique per user), ingredients_json (JSONB)
- instructions, prep_minutes, is_public, timestamps

**recipe_ingredients** (junction table)
- id, recipe_id (FK), ingredient_id (FK)
- recipe_name, ingredient_name (denormalized for debugging)
- Unique constraint on (recipe_id, ingredient_id)

**user_pantry**
- id, user_id (FK), ingredient_id (FK)
- ingredient_name (denormalized for debugging)
- Unique constraint on (user_id, ingredient_id)
- created_at timestamp

**Design Decisions:**
- Junction table enables proper many-to-many relationships
- Denormalized name fields improve debugging (can read tables without JOINs)
- JSONB for flexible ingredient storage and synonym matching
- B-tree indexes only (bootcamp-appropriate, no advanced GIN/FTS)

Load sample data (local dev): `psql $DATABASE_URL -f templates/recipe_pantry_api_production.sql`

## Endpoints

Auth (`/auth/*`):
- POST /signup – register user
- POST /login – get JWT token
- POST /signup-admin – admin registration (needs ADMIN_SECRET)

User (`/me/*`):
- GET/PUT/DELETE /me – profile management
- POST /me/recipes – create recipe (validates all ingredients exist)
- GET /me/recipes – user's recipes
- PUT/DELETE /me/recipes/{id} – update/delete recipe
- GET /me/pantry – user's pantry (array format)
- POST /me/pantry/ingredients – add ingredient to pantry
- DELETE /me/pantry/ingredients/{id} – remove ingredient
- PUT /me/pantry – replace entire pantry
- GET /me/recipes/available – recipe matching with synonym support

Admin (`/users/*`, `/recipes/*`):
- GET /users – all users
- GET/PUT/DELETE /users/{id} – user management
- GET /recipes – all recipes (with filters)
- GET/PUT/DELETE /recipes/{id} – recipe management

System:
- GET / – welcome message
- GET /health – health check
- GET /ingredients – reference list of all 2080 ingredients (fallback for validation errors)

## Testing

Run full test suite (against local development):
1. Import `tests/postman_test_collection.json` in Postman
2. Run collection (creates/deletes test data automatically)
3. Clean admin user (local only): `psql $DATABASE_URL -f tests/postman_cleanup_admin.sql`

⚠️ **Never run cleanup scripts against production database!**

156 assertions across 127 requests covering all endpoints, edge cases, auth flows.

## Code Quality

Linted with ruff and sqlfluff (see docs/LINTING.md for details).

Architecture: Refactored from monolithic main.py into modular structure with routers and helpers for better maintainability.

## Recipe Matching Logic

The `/me/recipes/available` endpoint works like this:
1. Gets what's in your pantry and any synonyms
2. Checks all your ingredients (so "milk" also matches "whole milk")
3. Looks at what each recipe needs
4. Figures out what percentage of ingredients you have
5. Shows recipes where you have enough ingredients (default 50%)

**Synonym Support Example:**
- User has "milk" in pantry
- Recipe needs "whole milk"
- Match successful! (synonyms: ["whole milk", "2% milk", "skim milk"])

**Why Botanical Accuracy Matters:**
- Sweet potatoes ≠ yams (different species, different cooking properties)
- User with "sweet potatoes" in pantry gets sweet potato recipes
- User with "yams" in pantry gets yam recipes
- Prevents matching recipes that won't work with what's actually in the kitchen

**Match Calculation:**
Recipe needs [eggs, milk, flour]. You have [eggs, milk]. Match = 66% (2 of 3 ingredients).

## Ingredient Validation System

**Why I compiled 2080 ingredients with synonyms:**

I wanted users to just type normal ingredient names without having to check a list first. With 2080 ingredients and all their synonyms in the database, pretty much any normal ingredient name will work:

**Most of the time it just works:**
```
POST /me/recipes with {"ingredients_json": ["eggs", "milk", "butter"]}
→ Recipe created (all ingredients found)
```

**If you use something that doesn't exist:**
```
POST /me/recipes with {"ingredients_json": ["eggs", "weird-spice-xyz"]}
→ Error: "Unknown ingredients: weird-spice-xyz. Use GET /ingredients to see all 2080 valid options."
```

**How it works:**
- The 2080 ingredients I added cover most cooking ingredients
- Synonyms mean "whole milk" works when the user types "milk"
- GET /ingredients shows them all alphabetically if you need to look one up
- But usually you won't need to because common ingredients are already there

## Requirements Checklist

- [x] FastAPI framework – full implementation with 20+ endpoints
- [x] Project documented – comprehensive README
- [x] Database schema – 5 normalized tables with relationships
- [x] Local server – localhost:8000 with auto-reload
- [x] PostgreSQL – recipe_pantry_api_dev database
- [x] GitHub repo – with .gitignore
- [x] .ENV file – all secrets configured
- [x] Server-DB connection – SQLAlchemy ORM with models
- [x] CRUD operations – users, recipes, pantry all covered
- [x] JWT auth – bcrypt passwords, 30-day tokens
- [x] /me endpoint – complete user management
- [x] Postman tests – 156 assertions across 127 requests with cleanup
- [x] Password encryption – bcrypt hashing
- [x] Unique emails – enforced in DB and code
- [x] API testing – 156 assertions across 127 requests
- [x] Swagger docs – auto-generated
- [x] POC ready – fully functional

## How to Deploy

1. Create database on Render first through "Postgres" service
2. Connect this GitHub repo to Render
3. Sign up for "Web Service" on Render and start configuring API
4. Copy all the environment variables from .env
5. Test with /health endpoint: `curl https://recipe-pantry-api.onrender.com/health`

Environment variables needed:
- DATABASE_URL (from the Render "Postgres" database)
- JWT_SECRET_KEY and SECRET_KEY (need to generate new ones)
- JWT_ALGORITHM and JWT_EXPIRATION_DAYS
- ADMIN_SECRET (for creating admin users)
- CORS_ORIGINS (set to `*` for portfolio/demo projects, or specific domains for production)
