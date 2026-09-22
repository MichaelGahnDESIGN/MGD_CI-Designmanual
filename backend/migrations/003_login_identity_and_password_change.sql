-- Login names are stored as keyed lookup hashes and encrypted display values.
-- must_change_password supports the first-login flow for provisioned accounts.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS username_lookup_hash BINARY(32) NULL AFTER email_lookup_hash,
  ADD COLUMN IF NOT EXISTS username_ciphertext MEDIUMBLOB NULL AFTER username_lookup_hash,
  ADD COLUMN IF NOT EXISTS username_nonce BINARY(12) NULL AFTER username_ciphertext,
  ADD COLUMN IF NOT EXISTS username_auth_tag BINARY(16) NULL AFTER username_nonce,
  ADD COLUMN IF NOT EXISTS username_key_version SMALLINT UNSIGNED NULL AFTER username_ciphertext,
  ADD COLUMN IF NOT EXISTS must_change_password TINYINT(1) NOT NULL DEFAULT 0 AFTER password_changed_at,
  ADD UNIQUE KEY users_username_lookup_hash_uq (username_lookup_hash);

-- Checksum: SHA-256 of this migration with the checksum value represented by
-- PENDING_CHECKSUM. The migration runner verifies that canonical value.
INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('003_login_identity_and_password_change', '05f926f2b4f324a42fb2384024183adf3b4df18f1d07ea369bc9a91f2822b32d')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
