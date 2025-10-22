-- ================================================================
-- Admin Cleanup Script for Recipe Pantry API Test Collection
-- ================================================================
--
-- PURPOSE:
--   Removes test admin users created by the Postman collection
--
-- WHEN TO RUN:
--   After running Recipe_Pantry_API_PRODUCTION_READY_v0.3.0 collection
--
-- WHY NEEDED:
--   Admin users cannot self-delete via API (safety feature)
--   This script removes the test admin user manually
--
-- WHAT GETS DELETED:
--   - Admin user (postman_admin@test.com)
--   - CASCADE: Admin's recipes (if any)
--   - CASCADE: Admin's pantry (if any)
--
-- ================================================================

-- Start transaction for safety
BEGIN;

-- Display current state BEFORE cleanup
SELECT
    '📊 BEFORE CLEANUP - Test Users Found:' AS message,
    COUNT(*) AS count
FROM users
WHERE email LIKE '%postman%' OR username LIKE '%postman%';

SELECT
    id,
    email,
    username,
    role,
    created_at
FROM users
WHERE email LIKE '%postman%' OR username LIKE '%postman%'
ORDER BY created_at;

-- Delete the test admin user (CASCADE handles related data)
-- This matches the collection variable: testAdminEmail = 'postman_admin@test.com'
DELETE FROM users
WHERE
    email = 'postman_admin@test.com'
    OR username = 'postman_admin';

-- Also clean up any other test admin users that might exist
-- (In case collection was run multiple times with failures)
DELETE FROM users
WHERE
    (email LIKE '%postman%' AND role = 'admin')
    OR (username LIKE '%postman%' AND role = 'admin');

-- Display cleanup results
SELECT
    '✅ AFTER CLEANUP - Remaining Test Users:' AS message,
    COUNT(*) AS count
FROM users
WHERE email LIKE '%postman%' OR username LIKE '%postman%';

-- Show any remaining test users (should be 0)
SELECT
    id,
    email,
    username,
    role,
    created_at
FROM users
WHERE email LIKE '%postman%' OR username LIKE '%postman%'
ORDER BY created_at;

-- Verify no orphaned test data remains
SELECT '🔍 Orphaned Data Check:' AS message;

SELECT
    'Recipes with postman emails' AS check_type,
    COUNT(*) AS count
FROM recipes AS r
INNER JOIN users AS u ON r.user_id = u.id
WHERE u.email LIKE '%postman%' OR u.username LIKE '%postman%';

SELECT
    'Pantry with postman users' AS check_type,
    COUNT(*) AS count
FROM user_pantry AS p
INNER JOIN users AS u ON p.user_id = u.id
WHERE u.email LIKE '%postman%' OR u.username LIKE '%postman%';

-- Final verification message
SELECT
    CASE
        WHEN
            EXISTS (
                SELECT 1 FROM users
                WHERE email LIKE '%postman%' OR username LIKE '%postman%'
            )
            THEN '❌ WARNING: Test users still remain!'
        ELSE '✅ SUCCESS: All test users removed!'
    END AS cleanup_status;

-- If everything looks good, commit the transaction
-- If there are issues, you can ROLLBACK instead
COMMIT;

-- ================================================================
-- USAGE:
--   psql $DATABASE_URL -f tests/postman_cleanup_admin.sql
--
-- EXAMPLE OUTPUT:
--   📊 BEFORE CLEANUP - Test Users Found: 1
--   ✅ AFTER CLEANUP - Remaining Test Users: 0
--   ✅ SUCCESS: All test users removed!
-- ================================================================
