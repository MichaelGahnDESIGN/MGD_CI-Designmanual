-- CMS foundation for the editable landing page and future platform copy.
-- Public reads are locale-scoped; writes require the server capability
-- cms.landing.edit. HTML/CSS and translation values are encrypted at rest.

CREATE TABLE IF NOT EXISTS cms_landing_pages (
  id BINARY(16) NOT NULL,
  locale VARCHAR(10) NOT NULL,
  content_ciphertext MEDIUMBLOB NOT NULL,
  content_nonce BINARY(12) NOT NULL,
  content_auth_tag BINARY(16) NOT NULL,
  content_key_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  revision_no INT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'published',
  updated_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY cms_landing_pages_locale_uq (locale),
  CONSTRAINT cms_landing_pages_user_fk FOREIGN KEY (updated_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cms_translation_entries (
  id BINARY(16) NOT NULL,
  locale VARCHAR(10) NOT NULL,
  translation_key VARCHAR(180) NOT NULL,
  value_ciphertext MEDIUMBLOB NOT NULL,
  value_nonce BINARY(12) NOT NULL,
  value_auth_tag BINARY(16) NOT NULL,
  value_key_version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'published',
  updated_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY cms_translation_entries_locale_key_uq (locale, translation_key),
  CONSTRAINT cms_translation_entries_user_fk FOREIGN KEY (updated_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO capabilities (id, `key`, label) VALUES
  (UNHEX('019C1B5EA50170008000000000000014'), 'cms.landing.view', 'Landingpage-Inhalte ansehen'),
  (UNHEX('019C1B5EA50170008000000000000015'), 'cms.landing.edit', 'Landingpage-Inhalte bearbeiten')
ON DUPLICATE KEY UPDATE label = VALUES(label);

INSERT INTO role_capabilities (role_id, capability_id) VALUES
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000014')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000015'))
ON DUPLICATE KEY UPDATE granted_at = granted_at;

-- The migration runner canonicalises the checksum value to PENDING_CHECKSUM
-- before hashing the file, so this record remains tamper-evident.
INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('004_cms_landing_i18n', 'd0ec31fe09558b76e3f585af6043711aa612ed4a9b06617bc85acc3224f3f9ba')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
