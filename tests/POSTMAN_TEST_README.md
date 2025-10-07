# Postman Test Collections - Complete API Test Suite

## Collections Available

### 🆕 Recipe_Pantry_API_Full_Test.postman_collection.json (Recommended)
- **Complete test coverage** with improved organization
- **Better cleanup** - systematically removes all test artifacts
- **Clear test data** - uses "postman_" prefix for all test users
- **Collection variables** - tracks all IDs for cleanup
- **~50+ tests** across 8 test suites

### Recipe_Pantry_API_Complete_Test.postman_collection.json
- Original comprehensive test suite
- Tests all functionality with different test data
- Also includes full cleanup

Both collections test **every endpoint** in the Recipe Pantry API and clean up all test data afterward, leaving your database in the **exact same state** as before running.

## 📋 What Gets Tested

### ✅ Comprehensive Coverage

1. **Authentication & Security**
   - User signup (with validation)
   - User login (with JWT tokens)
   - Admin user creation (with secret key)
   - Duplicate email/username prevention
   - Invalid password rejection
   - Unauthenticated request blocking

2. **User Profile Management**
   - Get own profile (`GET /me`)
   - Update own profile (`PUT /me`)
   - Self-deletion (`DELETE /me`)

3. **Recipe CRUD Operations**
   - Create private recipes
   - Create public recipes
   - List own recipes
   - Update own recipes
   - Delete own recipes
   - Duplicate recipe title prevention
   - Recipe ownership permissions

4. **Pantry Management**
   - Get pantry (auto-creates if missing)
   - Update pantry ingredients
   - Ingredient normalization (lowercase, sorted)

5. **Recipe Matching Algorithm**
   - 100% ingredient match threshold
   - 50% ingredient match threshold
   - Available vs missing ingredient tracking
   - Own recipe vs public recipe identification

6. **Admin Functionality**
   - Admin user creation with secret
   - View all users (admin only)
   - View all recipes (admin only)
   - View specific recipe by ID (admin only)
   - Admin authorization enforcement

7. **Database Viewer**
   - List table names (any authenticated user)
   - View table data (admin only)
   - Authorization checks

8. **Permissions & Authorization**
   - Multi-user scenarios
   - Cross-user recipe access prevention
   - Role-based access control (RBAC)

---

## 🚀 Quick Start

### Option 1: Automated Run (Recommended)

**Requirements:**
- API running: `uvicorn src.main:app --reload`
- Newman installed: `npm install -g newman`

**Run:**
```bash
cd postman
./run_tests_and_cleanup.sh
```

This script:
- ✅ Checks API health
- ✅ Captures database state before tests
- ✅ Runs all tests with Newman
- ✅ Cleans up admin user (bypasses API restriction)
- ✅ Verifies database restored to original state

---

### Option 2: Manual Run in Postman

**Steps:**

1. **Import Collection**
   - Open Postman
   - Click "Import"
   - Select `Recipe_Pantry_API_Complete_Test.postman_collection.json`

2. **Start Your API**
   ```bash
   uvicorn src.main:app --reload
   ```

3. **Run Collection**
   - Click "Collections" → "Recipe Pantry API - Complete Test Suite"
   - Click "Run" button
   - Click "Run Recipe Pantry API..."
   - Watch tests execute (should see all ✅)

4. **Manual Cleanup (Admin User)**

   The collection cannot delete the admin user (API safety feature).

   **Run cleanup SQL:**
   ```bash
   psql postgresql://David:david_pw_123@localhost/recipe_pantry_api_dev -f cleanup_test_admin.sql
   ```

   **OR manually:**
   ```bash
   psql postgresql://David:david_pw_123@localhost/recipe_pantry_api_dev
   DELETE FROM users WHERE email='admin@test.com';
   \q
   ```

---

## 📊 Expected Results

### Test Summary
- **Total Requests:** 40+
- **Total Tests:** 50+
- **Expected Pass Rate:** 100% ✅

### Sample Output
```
┌─────────────────────────┬────────────────────┬───────────────────┐
│                         │           executed │            failed │
├─────────────────────────┼────────────────────┼───────────────────┤
│              iterations │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│                requests │                 42 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│            test-scripts │                 84 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│      prerequest-scripts │                 42 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│              assertions │                 52 │                 0 │
└─────────────────────────┴────────────────────┴───────────────────┘
```

---

## 🧹 Cleanup Process

The collection is designed to leave **ZERO artifacts** in the database.

### Automatic Cleanup (During Collection Run)

1. **Delete User2's account** (via `DELETE /me`)
2. **Delete User1's recipes** (both private and public)
3. **Delete User1's account** (via `DELETE /me`)
   - Triggers CASCADE delete of:
     - User1's pantry
     - Any remaining User1 recipes

### Manual Cleanup Required

**Admin User:** Cannot self-delete via API (safety feature)

**Solution:** Run the provided SQL script:
```bash
cd postman
psql postgresql://David:david_pw_123@localhost/recipe_pantry_api_dev -f cleanup_test_admin.sql
```

This removes the test admin user: `admin@test.com`

---

## 🔍 Database State Verification

### Before Running Tests
```bash
psql postgresql://David:david_pw_123@localhost/recipe_pantry_api_dev

SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM recipes;
SELECT COUNT(*) FROM user_pantry;
```

### After Running Tests (with cleanup)
**Counts should be identical!**

---

## 📝 Collection Variables

The collection uses these variables to track test artifacts:

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `base_url` | API base URL | `http://localhost:8000` |
| `user_token` | User1 JWT token | `eyJ0eXAiOiJKV1...` |
| `admin_token` | Admin JWT token | `eyJ0eXAiOiJKV1...` |
| `user2_token` | User2 JWT token | `eyJ0eXAiOiJKV1...` |
| `test_user_id` | User1 ID for cleanup | `123` |
| `test_admin_id` | Admin ID for tracking | `124` |
| `test_user2_id` | User2 ID for cleanup | `125` |
| `test_recipe_id` | Recipe 1 ID for tests | `45` |
| `test_public_recipe_id` | Recipe 2 ID for tests | `46` |
| `test_pantry_id` | Pantry ID for tracking | `12` |

**Note:** Variables are auto-populated during test execution.

---

## 🛠️ Troubleshooting

### ❌ API Not Running
**Error:** Connection refused on `localhost:8000`

**Fix:**
```bash
cd /Users/David/Documents/Development/recipe_pantry_api
uvicorn src.main:app --reload
```

---

### ❌ Tests Fail on First Run
**Issue:** Database might have leftover test data

**Fix:**
```bash
# Clean up any existing test users
psql postgresql://David:david_pw_123@localhost/recipe_pantry_api_dev << EOF
DELETE FROM users WHERE email IN ('testuser@example.com', 'user2@test.com', 'admin@test.com');
EOF
```

---

### ❌ "Admin cannot self-delete" Error in Cleanup
**Status:** This is EXPECTED behavior!

The API prevents admins from deleting themselves for safety. The collection catches this and notes it in the output.

**Fix:** Run the SQL cleanup script as documented above.

---

### ❌ Newman Not Found
**Error:** `newman: command not found`

**Fix:**
```bash
npm install -g newman
```

Or run manually in Postman GUI instead.

---

## 📚 What Each Test Section Does

### 0. Setup & Health Check
- Verifies API is responsive
- Checks database connection
- Validates root endpoint

### 1. Authentication
- Creates test user (`testuser@example.com`)
- Tests login with correct/incorrect passwords
- Validates JWT token generation
- Tests duplicate email prevention

### 2. User Profile
- Gets authenticated user profile
- Updates profile fields
- Tests unauthenticated access (should fail)

### 3. Recipe CRUD
- Creates private recipe ("Test Pasta Carbonara")
- Creates public recipe ("Test Tomato Soup")
- Lists user's recipes
- Updates recipe (changes prep_minutes)
- Tests duplicate recipe prevention

### 4. Pantry Management
- Gets pantry (auto-creates if needed)
- Updates pantry with ingredients
- Validates normalization (lowercase, sorted)

### 5. Recipe Matching
- Tests 100% match threshold
- Tests 50% match threshold
- Validates available/missing ingredient calculation
- Checks recipe ownership flags

### 6. Admin Tests
- Creates admin user with secret key
- Logs in as admin
- Tests admin viewing all users
- Tests admin viewing all recipes
- Tests admin viewing specific recipe
- Validates non-admin cannot access admin endpoints

### 7. Database Viewer
- Tests user viewing table names
- Tests admin viewing table data
- Validates admin-only restrictions

### 8. Permissions
- Creates second user
- Tests cross-user recipe access (should fail)
- Validates ownership permissions

### 9. Cleanup
- Deletes all recipes
- Deletes User2 account
- Deletes User1 account (triggers cascade)
- Attempts admin deletion (blocked by API)
- Final health check

---

## 🎯 Why This Collection Is Awesome

1. **100% API Coverage** - Every endpoint tested
2. **Zero Side Effects** - Database restored perfectly
3. **Real-World Scenarios** - Multi-user, permissions, edge cases
4. **Self-Documenting** - Clear test names and assertions
5. **Automated Cleanup** - No manual database cleanup needed*
6. **Production-Safe** - Won't interfere with real data

\* *Except admin user (1 SQL command)*

---

## 📖 Files in This Directory

```
postman/
├── Recipe_Pantry_API_Complete_Test.postman_collection.json
│   └── The main Postman collection (import this)
│
├── cleanup_test_admin.sql
│   └── SQL script to remove test admin user
│
├── run_tests_and_cleanup.sh
│   └── Automated test runner with cleanup
│
└── README.md
    └── This file
```

---

## 🚦 Running Tests in CI/CD

This collection is perfect for continuous integration:

```yaml
# Example GitHub Actions workflow
- name: Run API Tests
  run: |
    uvicorn src.main:app &
    sleep 5
    cd postman
    newman run Recipe_Pantry_API_Complete_Test.postman_collection.json
    psql $DATABASE_URL -f cleanup_test_admin.sql
```

---

## ✅ Success Criteria

After running, you should see:

- ✅ All tests pass (green checkmarks)
- ✅ Database user count unchanged
- ✅ Database recipe count unchanged
- ✅ Database pantry count unchanged
- ✅ No test users remain (`testuser@example.com`, `user2@test.com`, `admin@test.com`)
- ✅ No test recipes remain

**Perfect cleanup = Database looks like tests never ran!**

---

## 🤝 Contributing

If you add new endpoints to the API:

1. Add test requests to the appropriate section
2. Add assertions to validate responses
3. Add cleanup steps in section 9
4. Update this README with the new tests

---

**Happy Testing! 🎉**
