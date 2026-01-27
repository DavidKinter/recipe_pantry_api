from src.auth_utils import hash_password, verify_password


def test_hash_password_creates_different_hash():
    """Same password should create different hashes (due to salt)"""

    password = "secret123"
    hash1 = hash_password(password)
    hash2 = hash_password(password)

    assert hash1 != hash2  # Different salts
    assert verify_password(password, hash1)  # Both verify
    assert verify_password(password, hash2)


def test_verify_password_rejects_wrong_password():
    """Wrong password should not verify"""

    password = "correct"
    wrong = "incorrect"
    hashed = hash_password(password)

    assert verify_password(password, hashed) == True
    assert verify_password(wrong, hashed) == False
