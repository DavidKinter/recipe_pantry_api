# Postman Collection Setup Guide

This guide explains how to configure and run the Recipe Pantry API test collection (`postman_test_collection.json`).

## Prerequisites

- [Postman](https://www.postman.com/downloads/) installed
- Recipe Pantry API server running (default: `http://localhost:8000`)
- PostgreSQL database initialized with exactly 2080 ingredients (test expects this count)

## Quick Start

### 1. Import the Collection

1. Open Postman
2. Click **Import** button
3. Select `tests/postman_test_collection.json`
4. Click **Import**

### 2. Configure Collection Variables

**CRITICAL**: The collection will fail without proper variable configuration.

1. Click on **Recipe Pantry API - PRODUCTION READY v0.1.0 (156 Assertions)** collection
2. Go to the **Variables** tab
3. Configure these variables:

   | Variable | Required | Default | Description |
   |----------|----------|---------|-------------|
   | `adminSecret` | **YES** | *(empty)* | Must match your `.env` ADMIN_SECRET or test at line 441 fails |
   | `baseUrl` | No | `http://localhost:8000` | Only change if using different port |

   ⚠️ **Test will fail at "Register Admin User" (request #3 in section 2) without adminSecret**

### 3. Verify Prerequisites

Before running tests, verify:

✅ **Database has exactly 2080 ingredients**
```sql
-- Check ingredient count (test expects 2080)
SELECT COUNT(*) FROM ingredients;
```

✅ **API version returns "0.1.0"**
```bash
curl http://localhost:8000/ | grep "0.1.0"
```

✅ **adminSecret is configured in Postman** (not in the collection file for security)

## Running the Tests

### Option 1: Run Entire Collection

1. Click **Recipe Pantry API - PRODUCTION READY v0.1.0**
2. Click **Run** button (or use Runner)
3. Select all folders
4. Click **Run Recipe Pantry API**

**Expected Output**: ✅ All 156 assertions should pass

### Option 2: Run Specific Section

Navigate to any folder and click **Run** to execute only those tests:

- **1. System Health Checks** - 4 tests
- **2. User Registration & Auth** - 13 tests
- **3. User Profile Management** - 6 tests
- **4. Recipe Management** - 10 tests
- **5. Ingredient Reference** - 4 tests
- **6. Pantry Management** - 16 tests
- **7. Recipe Matching** - 7 tests
- **8. Admin Operations** - 6 tests
- **9. Error Handling Tests** - 11 tests
- **11A. Concurrency & Race Conditions** - 8 tests
- **11B. CASCADE Delete Verification** - 10 tests
- **11C. Security Tests** - 9 tests
- **11D. Boundary Value Tests** - 16 tests
- **11E. 422 Validation Errors** - 8 tests
- **10. Edge Cases & Boundaries** - 6 tests
- **10. CLEANUP** - 17 tests

## Post-Test Cleanup

The collection performs specific cleanup operations as documented in the test scripts:

### Automated Cleanup (Pre-Test Section, lines 11-229)
The collection's "0. Pre-Test Cleanup" section automatically:
- Attempts to login existing test users (lines 14-149)
- Deletes them if found (lines 57-199)
- Uses conditional execution via `X-Skip-Request` header (line 65)

### Manual Admin Cleanup Required
As shown in line 208-209 of the collection, admin cleanup requires manual SQL:

```bash
# The collection outputs this reminder in the console:
psql $DATABASE_URL -f tests/postman_cleanup_admin.sql
```

This is because the admin user cannot self-delete (safety feature in the API).

## Troubleshooting

### ❌ Test Failures at Specific Points

**"Register Admin User" fails (Test #3 in Section 2)**
- Cause: `adminSecret` variable not set in Postman
- Fix: Set the variable as described in section 2

**"Returns 2080 ingredients" fails (Test in Section 5)**
- Cause: Database doesn't have exactly 2080 ingredients
- The test at line 1058 expects exactly this count
- Fix: Initialize database with production data

**"Response has correct structure" fails (Test #1 in Section 1)**
- Cause: API version not "0.1.0"
- The test at line 249 checks for this exact version
- Fix: Ensure you're running the correct API version

### ❌ Tests fail after previous run

**Problem**: Leftover data from previous test runs

**Solution**:
```bash
# Clean up all test data
psql $DATABASE_URL -f tests/postman_cleanup_admin.sql

# Or manually delete test users
psql $DATABASE_URL -c "DELETE FROM users WHERE email LIKE '%postman%'"
```

## Collection Variables Reference

### Pre-configured Variables (lines 6247-6382)

| Variable | Default | Set At | Used In |
|----------|---------|--------|---------|
| `baseUrl` | `http://localhost:8000` | line 6250 | All requests |
| `adminSecret` | *(empty)* | line 6290 | Line 441 (Admin signup) |
| `testEmail1` | `postman_test_user1@test.com` | line 6255 | User 1 operations |
| `testEmail2` | `postman_test_user2@test.com` | line 6265 | User 2 operations |
| `testAdminEmail` | `postman_admin@test.com` | line 6275 | Admin operations |
| `testPassword` | `test_password_123` | line 6285 | All auth operations |

### Variables Set During Test Execution

| Variable | Set At Line | Purpose |
|----------|-------------|---------|
| `cleanupToken1/2` | 22, 116 | Pre-test cleanup tokens |
| `testUserId1/2/Admin` | 326, 372, 417 | User ID storage |
| `userToken1/2/adminToken` | 470, 514, 558 | JWT tokens for auth |
| `recipeId1/2/3` | 764, 822, 884 | Created recipe IDs |
| `ingredientId1-5` | 1076-1080 | First 5 ingredient IDs |
| `raceTestRecipeId` | line 6385 | Race condition testing |
| `raceTestUserId1` | line 6390 | Race condition user |
| `recipe2Created` | line 6395 | Recipe creation tracking |

## Test Coverage

The collection includes **156 assertions across 127 requests** covering:

### Core Functionality
- ✅ Authentication & authorization (JWT)
- ✅ User profile CRUD operations
- ✅ Recipe management (create, read, update, delete)
- ✅ Pantry ingredient tracking
- ✅ Recipe matching algorithm
- ✅ Admin operations

### Quality & Security
- ✅ Input validation (Pydantic 422 errors)
- ✅ Boundary value testing
- ✅ Concurrency & race conditions
- ✅ CASCADE delete verification
- ✅ Role-based access control
- ✅ Error handling edge cases

## Known Test Expectations

Based on the collection's test scripts, these exact values are expected:
- **API Version**: "0.1.0" (checked at line 249)
- **Ingredient Count**: 2080 (checked at line 1058)
- **Database Status**: "connected" (checked at line 284)
- **Token Type**: "bearer" (checked at line 469)

## Need Help?

- 📖 [API Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/DavidKinter/recipe_pantry_api/issues)
- 📧 Contact: david.kinter@hotmail.com

---

**Pro Tip**: Save your Postman workspace after setting the `adminSecret` variable. Postman will remember your configuration for future sessions.
