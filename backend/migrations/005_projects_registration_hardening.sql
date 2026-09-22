-- Persisted project basis, encrypted project description and public
-- registration abuse protection. The migration is forward-only and idempotent.

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS email_nonce BINARY(12) NULL AFTER email_ciphertext,
  ADD COLUMN IF NOT EXISTS email_auth_tag BINARY(16) NULL AFTER email_nonce;

ALTER TABLE projects
  ADD COLUMN IF NOT EXISTS description_ciphertext MEDIUMBLOB NULL AFTER company_key_version,
  ADD COLUMN IF NOT EXISTS description_nonce BINARY(12) NULL AFTER description_ciphertext,
  ADD COLUMN IF NOT EXISTS description_auth_tag BINARY(16) NULL AFTER description_nonce,
  ADD COLUMN IF NOT EXISTS description_key_version SMALLINT UNSIGNED NULL AFTER description_auth_tag,
  ADD COLUMN IF NOT EXISTS font_family VARCHAR(80) NOT NULL DEFAULT 'Open Sans' AFTER status;

CREATE TABLE IF NOT EXISTS auth_rate_limit_events (
  id BINARY(16) NOT NULL,
  scope VARCHAR(40) NOT NULL,
  subject_hash BINARY(32) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  KEY auth_rate_limit_events_lookup_idx (scope, subject_hash, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('005_projects_registration_hardening', 'c5fc99c3e822545575fd88985b2da6b0e61a6bfc70b8068daf707a77b3746f81')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
