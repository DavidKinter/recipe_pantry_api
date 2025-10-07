-- Cleanup script to remove test admin user created by Postman collection
-- Run this after the Postman collection completes

-- Delete the test admin user (cascade will handle related data)
DELETE FROM users
WHERE
    email = 'postman_admin@test.com'
    OR username = 'postman_admin';

-- Verify cleanup
SELECT 'Cleanup complete. Remaining test users:' AS message;
SELECT
    id,
    email,
    username,
    role
FROM users
WHERE email LIKE '%postman%' OR username LIKE '%postman%';
