-- Michael Gahn DESIGN CI BUILDER
-- 002_projects_manuals_entitlements.sql
--
-- Project, manual and entitlement foundation. All customer-readable fields
-- are encrypted by the backend before persistence. Object storage keys are
-- internal identifiers; never treat them as public access URLs.

ALTER TABLE auth_sessions
  ADD COLUMN IF NOT EXISTS csrf_token_hash BINARY(32) NULL AFTER token_hash;

CREATE TABLE IF NOT EXISTS capabilities (
  id BINARY(16) NOT NULL,
  `key` VARCHAR(96) NOT NULL,
  label VARCHAR(160) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY capabilities_key_uq (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_capabilities (
  role_id BINARY(16) NOT NULL,
  capability_id BINARY(16) NOT NULL,
  granted_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (role_id, capability_id),
  CONSTRAINT role_capabilities_role_fk FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE,
  CONSTRAINT role_capabilities_capability_fk FOREIGN KEY (capability_id) REFERENCES capabilities (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS projects (
  id BINARY(16) NOT NULL,
  owner_user_id BINARY(16) NOT NULL,
  name_ciphertext MEDIUMBLOB NOT NULL,
  name_nonce BINARY(12) NOT NULL,
  name_auth_tag BINARY(16) NOT NULL,
  name_key_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  company_ciphertext MEDIUMBLOB NULL,
  company_nonce BINARY(12) NULL,
  company_auth_tag BINARY(16) NULL,
  company_key_version SMALLINT UNSIGNED NULL,
  status ENUM('draft', 'active', 'archived', 'deleted') NOT NULL DEFAULT 'draft',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  archived_at DATETIME(6) NULL,
  deleted_at DATETIME(6) NULL,
  PRIMARY KEY (id),
  KEY projects_owner_status_idx (owner_user_id, status, created_at),
  CONSTRAINT projects_owner_user_fk FOREIGN KEY (owner_user_id) REFERENCES users (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_members (
  project_id BINARY(16) NOT NULL,
  user_id BINARY(16) NOT NULL,
  membership_role ENUM('owner', 'editor', 'viewer') NOT NULL,
  invited_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (project_id, user_id),
  KEY project_members_user_idx (user_id, project_id),
  CONSTRAINT project_members_project_fk FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT project_members_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT project_members_inviter_fk FOREIGN KEY (invited_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS manual_documents (
  id BINARY(16) NOT NULL,
  project_id BINARY(16) NOT NULL,
  document_type ENUM('design_manual', 'social_media_codex') NOT NULL,
  schema_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  content_ciphertext MEDIUMBLOB NOT NULL,
  content_nonce BINARY(12) NOT NULL,
  content_auth_tag BINARY(16) NOT NULL,
  content_key_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  revision_no INT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
  created_by_user_id BINARY(16) NULL,
  updated_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY manual_documents_project_type_uq (project_id, document_type),
  KEY manual_documents_project_status_idx (project_id, status),
  CONSTRAINT manual_documents_project_fk FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT manual_documents_created_by_fk FOREIGN KEY (created_by_user_id) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT manual_documents_updated_by_fk FOREIGN KEY (updated_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS media_assets (
  id BINARY(16) NOT NULL,
  project_id BINARY(16) NOT NULL,
  storage_key_ciphertext MEDIUMBLOB NOT NULL,
  storage_key_nonce BINARY(12) NOT NULL,
  storage_key_auth_tag BINARY(16) NOT NULL,
  storage_key_key_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  original_name_ciphertext MEDIUMBLOB NULL,
  original_name_nonce BINARY(12) NULL,
  original_name_auth_tag BINARY(16) NULL,
  original_name_key_version SMALLINT UNSIGNED NULL,
  media_kind ENUM('logo', 'reference_image', 'manual_image', 'export') NOT NULL,
  mime_type VARCHAR(128) NOT NULL,
  byte_size BIGINT UNSIGNED NOT NULL,
  sha256 BINARY(32) NOT NULL,
  created_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  PRIMARY KEY (id),
  KEY media_assets_project_kind_idx (project_id, media_kind, deleted_at),
  KEY media_assets_sha256_idx (sha256),
  CONSTRAINT media_assets_project_fk FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
  CONSTRAINT media_assets_created_by_fk FOREIGN KEY (created_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_slot_grants (
  id BINARY(16) NOT NULL,
  user_id BINARY(16) NOT NULL,
  source ENUM('free', 'referral', 'store', 'admin') NOT NULL,
  source_reference_hash BINARY(32) NULL,
  granted_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  revoked_at DATETIME(6) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY project_slot_grants_source_uq (user_id, source, source_reference_hash),
  KEY project_slot_grants_active_idx (user_id, revoked_at),
  CONSTRAINT project_slot_grants_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS referral_codes (
  id BINARY(16) NOT NULL,
  owner_user_id BINARY(16) NOT NULL,
  code_hash BINARY(32) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  disabled_at DATETIME(6) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY referral_codes_hash_uq (code_hash),
  KEY referral_codes_owner_active_idx (owner_user_id, disabled_at),
  CONSTRAINT referral_codes_owner_fk FOREIGN KEY (owner_user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS referral_redemptions (
  id BINARY(16) NOT NULL,
  referral_code_id BINARY(16) NOT NULL,
  invited_user_id BINARY(16) NOT NULL,
  qualified_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY referral_redemptions_invited_user_uq (invited_user_id),
  KEY referral_redemptions_code_idx (referral_code_id, qualified_at),
  CONSTRAINT referral_redemptions_code_fk FOREIGN KEY (referral_code_id) REFERENCES referral_codes (id) ON DELETE RESTRICT,
  CONSTRAINT referral_redemptions_invited_user_fk FOREIGN KEY (invited_user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_rate_limits (
  limiter_key_hash BINARY(32) NOT NULL,
  bucket_started_at DATETIME(6) NOT NULL,
  attempts SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (limiter_key_hash, bucket_started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Static built-in roles are not user identities. They are deterministic so
-- role-capability assignments can be safely seeded in subsequent migrations.
INSERT INTO roles (id, slug, label) VALUES
  (UNHEX('019C1B5EA50170008000000000000001'), 'member', 'Mitglied'),
  (UNHEX('019C1B5EA50170008000000000000002'), 'admin', 'Administration')
ON DUPLICATE KEY UPDATE label = VALUES(label);

INSERT INTO capabilities (id, `key`, label) VALUES
  (UNHEX('019C1B5EA50170008000000000000011'), 'admin.access', 'Administration öffnen'),
  (UNHEX('019C1B5EA50170008000000000000012'), 'users.manage', 'Nutzer verwalten'),
  (UNHEX('019C1B5EA50170008000000000000013'), 'entitlements.manage', 'Entitlements verwalten')
ON DUPLICATE KEY UPDATE label = VALUES(label);

INSERT INTO role_capabilities (role_id, capability_id) VALUES
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000011')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000012')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000013'))
ON DUPLICATE KEY UPDATE granted_at = granted_at;

-- Checksum: SHA-256 of this migration with the checksum value represented by
-- PENDING_CHECKSUM. The migration runner verifies that canonical value.
INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('002_projects_manuals_entitlements', 'cf23cea901d7633d228387f77c4d5521a684da5d4fd02fdc2140402573082cb0')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
