-- CI BUILDER: Backoffice, Tarifkatalog und revisionsfähige Zahlungsübersicht.
--
-- Es werden ausdrücklich keine Karten-, IBAN-, Rechnungsadress- oder Stripe-
--Kundendaten gespeichert. Provider-Referenzen liegen ausschließlich als
--HMAC-Hash vor, damit Webhook-Ereignisse idempotent bleiben und im Backoffice
--keine fremden Zahlungsidentitäten offengelegt werden.

CREATE TABLE IF NOT EXISTS billing_plans (
  slug VARCHAR(32) NOT NULL,
  label VARCHAR(64) NOT NULL,
  monthly_price_cents INT UNSIGNED NOT NULL DEFAULT 0,
  yearly_price_cents INT UNSIGNED NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  project_slots SMALLINT UNSIGNED NOT NULL,
  storage_bytes BIGINT UNSIGNED NOT NULL,
  logo_variant_limit SMALLINT UNSIGNED NOT NULL,
  font_family_limit SMALLINT UNSIGNED NOT NULL,
  template_limit SMALLINT UNSIGNED NOT NULL,
  core_features_included TINYINT(1) NOT NULL DEFAULT 1,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  is_available TINYINT(1) NOT NULL DEFAULT 0,
  sort_order SMALLINT UNSIGNED NOT NULL,
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (slug),
  CONSTRAINT billing_plans_price_chk CHECK (yearly_price_cents <= monthly_price_cents * 12)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS account_entitlements (
  id BINARY(16) NOT NULL,
  user_id BINARY(16) NOT NULL,
  plan_slug VARCHAR(32) NOT NULL,
  source ENUM('free', 'stripe', 'admin', 'referral', 'purchase') NOT NULL,
  source_reference_hash BINARY(32) NULL,
  status ENUM('active', 'scheduled', 'expired', 'revoked') NOT NULL DEFAULT 'active',
  starts_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  ends_at DATETIME(6) NULL,
  created_by_user_id BINARY(16) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY account_entitlements_source_uq (user_id, source, source_reference_hash),
  KEY account_entitlements_effective_idx (user_id, status, starts_at, ends_at),
  CONSTRAINT account_entitlements_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT account_entitlements_plan_fk FOREIGN KEY (plan_slug) REFERENCES billing_plans (slug) ON DELETE RESTRICT,
  CONSTRAINT account_entitlements_actor_fk FOREIGN KEY (created_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS billing_transactions (
  id BINARY(16) NOT NULL,
  user_id BINARY(16) NULL,
  plan_slug VARCHAR(32) NULL,
  provider ENUM('stripe') NOT NULL,
  provider_mode ENUM('test', 'live') NOT NULL,
  provider_event_hash BINARY(32) NOT NULL,
  provider_transaction_hash BINARY(32) NULL,
  transaction_kind ENUM('checkout', 'invoice', 'refund', 'dispute') NOT NULL,
  status ENUM('pending', 'paid', 'failed', 'refunded', 'disputed') NOT NULL,
  amount_cents INT UNSIGNED NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  occurred_at DATETIME(6) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY billing_transactions_event_uq (provider, provider_mode, provider_event_hash),
  KEY billing_transactions_user_occurred_idx (user_id, occurred_at),
  KEY billing_transactions_status_occurred_idx (status, occurred_at),
  CONSTRAINT billing_transactions_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT billing_transactions_plan_fk FOREIGN KEY (plan_slug) REFERENCES billing_plans (slug) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS billing_subscriptions (
  id BINARY(16) NOT NULL,
  user_id BINARY(16) NOT NULL,
  plan_slug VARCHAR(32) NOT NULL,
  provider ENUM('stripe') NOT NULL,
  provider_mode ENUM('test', 'live') NOT NULL,
  provider_subscription_hash BINARY(32) NOT NULL,
  billing_interval ENUM('month', 'year') NOT NULL,
  status ENUM('trialing', 'active', 'past_due', 'canceled', 'unpaid', 'incomplete') NOT NULL,
  current_period_end DATETIME(6) NULL,
  canceled_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  UNIQUE KEY billing_subscriptions_provider_uq (provider, provider_mode, provider_subscription_hash),
  KEY billing_subscriptions_user_status_idx (user_id, status),
  CONSTRAINT billing_subscriptions_user_fk FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT billing_subscriptions_plan_fk FOREIGN KEY (plan_slug) REFERENCES billing_plans (slug) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Moderation arbeitet ausschließlich mit dokumentierten Fällen. Die optionale
--Beschreibung ist verschlüsselt; Moderator:innen erhalten keine Projektmedien,
--E-Mails, Zahlungsdetails oder Rechteverwaltung.
CREATE TABLE IF NOT EXISTS moderation_cases (
  id BINARY(16) NOT NULL,
  subject_type ENUM('account', 'project', 'content') NOT NULL,
  subject_id BINARY(16) NULL,
  category VARCHAR(64) NOT NULL,
  priority ENUM('low', 'normal', 'high') NOT NULL DEFAULT 'normal',
  status ENUM('open', 'in_review', 'resolved', 'closed') NOT NULL DEFAULT 'open',
  description_ciphertext MEDIUMBLOB NULL,
  description_nonce BINARY(12) NULL,
  description_auth_tag BINARY(16) NULL,
  resolution_ciphertext MEDIUMBLOB NULL,
  resolution_nonce BINARY(12) NULL,
  resolution_auth_tag BINARY(16) NULL,
  opened_by_user_id BINARY(16) NULL,
  assigned_to_user_id BINARY(16) NULL,
  resolved_by_user_id BINARY(16) NULL,
  resolved_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (id),
  KEY moderation_cases_status_assignee_idx (status, assigned_to_user_id, updated_at),
  CONSTRAINT moderation_cases_opened_by_fk FOREIGN KEY (opened_by_user_id) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT moderation_cases_assigned_to_fk FOREIGN KEY (assigned_to_user_id) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT moderation_cases_resolved_by_fk FOREIGN KEY (resolved_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (id, slug, label) VALUES
  (UNHEX('019C1B5EA50170008000000000000003'), 'moderator', 'Moderation')
ON DUPLICATE KEY UPDATE label = VALUES(label);

INSERT INTO capabilities (id, `key`, label) VALUES
  (UNHEX('019C1B5EA50170008000000000000020'), 'backoffice.access', 'Backoffice öffnen'),
  (UNHEX('019C1B5EA50170008000000000000021'), 'users.status.manage', 'Kontostatus verwalten'),
  (UNHEX('019C1B5EA50170008000000000000022'), 'roles.manage', 'Rollen verwalten'),
  (UNHEX('019C1B5EA50170008000000000000023'), 'billing.read', 'Zahlungsübersicht ansehen'),
  (UNHEX('019C1B5EA50170008000000000000024'), 'billing.catalog.manage', 'Tarifkatalog verwalten'),
  (UNHEX('019C1B5EA50170008000000000000025'), 'moderation.case.read', 'Moderationsfälle ansehen'),
  (UNHEX('019C1B5EA50170008000000000000026'), 'moderation.case.manage', 'Moderationsfälle bearbeiten'),
  (UNHEX('019C1B5EA50170008000000000000027'), 'security.audit.read', 'Sicherheitsaudit ansehen')
ON DUPLICATE KEY UPDATE label = VALUES(label);

-- Administrator:innen erhalten die neuen Rechte als Rollen-Bundle. Die
--Backend-Routen prüfen dennoch jede einzelne Fähigkeit und vertrauen nie auf
--eine sichtbare UI-Schaltfläche.
INSERT INTO role_capabilities (role_id, capability_id) VALUES
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000020')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000021')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000022')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000023')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000024')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000025')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000026')),
  (UNHEX('019C1B5EA50170008000000000000002'), UNHEX('019C1B5EA50170008000000000000027')),
  (UNHEX('019C1B5EA50170008000000000000003'), UNHEX('019C1B5EA50170008000000000000020')),
  (UNHEX('019C1B5EA50170008000000000000003'), UNHEX('019C1B5EA50170008000000000000025')),
  (UNHEX('019C1B5EA50170008000000000000003'), UNHEX('019C1B5EA50170008000000000000026'))
ON DUPLICATE KEY UPDATE granted_at = granted_at;

INSERT INTO billing_plans (slug, label, monthly_price_cents, yearly_price_cents, currency, project_slots, storage_bytes, logo_variant_limit, font_family_limit, template_limit, core_features_included, is_public, is_available, sort_order) VALUES
  ('free', 'Free', 0, 0, 'EUR', 1, 104857600, 1, 0, 1, 1, 1, 1, 10),
  ('creator', 'Creator', 900, 9000, 'EUR', 4, 524288000, 3, 1, 3, 1, 1, 0, 20),
  ('studio', 'Studio', 1900, 19000, 'EUR', 12, 1610612736, 8, 3, 8, 1, 1, 0, 30),
  ('ultimate', 'Ultimate', 4900, 49000, 'EUR', 25, 3221225472, 20, 10, 20, 1, 1, 0, 40)
ON DUPLICATE KEY UPDATE
  label = VALUES(label), monthly_price_cents = VALUES(monthly_price_cents), yearly_price_cents = VALUES(yearly_price_cents),
  project_slots = VALUES(project_slots), storage_bytes = VALUES(storage_bytes), logo_variant_limit = VALUES(logo_variant_limit),
  font_family_limit = VALUES(font_family_limit), template_limit = VALUES(template_limit), core_features_included = VALUES(core_features_included),
  is_public = VALUES(is_public), is_available = VALUES(is_available), sort_order = VALUES(sort_order);

-- Checksum: SHA-256 of this migration with PENDING_CHECKSUM substituted.
INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('007_backoffice_billing_moderation', 'e58a6c90ea0122867dd4920e838e00e3b6a1c8c7af92f2a74ad835bab3ef2eff')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
