-- 006_external_image_references.sql
--
-- Öffentliche HTTPS-Bildreferenzen sind eine speichersparende Alternative zum
-- privaten Upload. Die URLs liegen verschlüsselt in den Projektdaten; der
-- Server lädt sie nie selbst und wird daher nicht zum Abruf-Proxy.

ALTER TABLE projects
  ADD COLUMN IF NOT EXISTS logo_external_url_ciphertext MEDIUMBLOB NULL AFTER description_auth_tag,
  ADD COLUMN IF NOT EXISTS logo_external_url_nonce BINARY(12) NULL AFTER logo_external_url_ciphertext,
  ADD COLUMN IF NOT EXISTS logo_external_url_auth_tag BINARY(16) NULL AFTER logo_external_url_nonce,
  ADD COLUMN IF NOT EXISTS reference_image_external_url_ciphertext MEDIUMBLOB NULL AFTER logo_external_url_auth_tag,
  ADD COLUMN IF NOT EXISTS reference_image_external_url_nonce BINARY(12) NULL AFTER reference_image_external_url_ciphertext,
  ADD COLUMN IF NOT EXISTS reference_image_external_url_auth_tag BINARY(16) NULL AFTER reference_image_external_url_nonce;

-- Checksum: SHA-256 dieser Datei, während PENDING_CHECKSUM als Platzhalter
-- eingetragen ist. Die Zeile dokumentiert die bei der Ausführung geprüfte
-- Migrationsfassung, ohne geheime Daten zu speichern.
INSERT INTO schema_migrations (version, checksum_sha256)
VALUES ('006_external_image_references', 'beaa1b2b06c333bb581db8b04592bd7e6b03c3516c1dea06f8239cfc2f00e700')
ON DUPLICATE KEY UPDATE checksum_sha256 = checksum_sha256;
