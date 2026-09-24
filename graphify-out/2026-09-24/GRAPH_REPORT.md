# Graph Report - Design-Manual-Editor  (2026-09-24)

## Corpus Check
- 62 files · ~39,614 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 16 file(s) not represented in the graph (top: (none) 13, .css 2, .lock 1)

## Summary
- 703 nodes · 831 edges · 55 communities (39 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2bf54246`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- main.dart
- legal_page.dart
- password_reset_pages.dart
- project_repository.dart
- account_page.dart
- index.php
- StatelessWidget
- legal_document.dart
- widget_test.dart
- landing_layout.dart
- cookie_consent.dart
- Daten, Sicherheit und Datenschutz
- Michael Gahn DESIGN – CI BUILDER
- brand_asset_picker_types.dart
- brand_asset_picker_web.dart
- manifest.json
- 002_projects_manuals_entitlements.sql
- browser_storage_web.dart
- 001_identity_security_foundation.sql
- plan_catalog.dart
- brand_asset_picker_stub.dart
- Roadmap
- AGENTS.md
- Landing-CMS und lokales Designsystem
- Produktanforderungen — Michael Gahn DESIGN CI BUILDER
- [Unreleased]
- Architektur
- Lokale Schriftbibliothek und Font-Upload
- Release gates
- landing-editor.js
- Inhaltsmodell für professionelle Designmanuals
- Produktvision
- Security Policy
- browser_storage_stub.dart
- Mitwirken
- BrandAssetPicker
- theme_preference_stub.dart
- CI BUILDER Flutter Webapp
- 004_cms_landing_i18n.sql
- Backend
- PULL_REQUEST_TEMPLATE.md
- browser_storage.dart
- theme_preference.dart
- build
- ThemeToggleScope
- 005_projects_registration_hardening.sql
- manual-schema.md
- research-sources.md
- backoffice_repository.dart
- backoffice_page.dart
- 007_backoffice_billing_moderation.sql

## God Nodes (most connected - your core abstractions)
1. `respond()` - 14 edges
2. `pdo()` - 13 edges
3. `Daten, Sicherheit und Datenschutz` - 10 edges
4. `Roadmap` - 7 edges
5. `enforceRateLimit()` - 6 edges
6. `auditEvent()` - 6 edges
7. `requireFreshAdminPassword()` - 6 edges
8. `Landing-CMS und lokales Designsystem` - 6 edges
9. `Produktanforderungen — Michael Gahn DESIGN CI BUILDER` - 6 edges
10. `BrandAssetPicker` - 5 edges

## Surprising Connections (you probably didn't know these)
- `_UnsupportedAssetPicker` --implements--> `BrandAssetPicker`  [EXTRACTED]
  app/lib/features/onboarding/brand_asset_picker_stub.dart → app/lib/features/onboarding/brand_asset_picker_types.dart
- `_WebBrandAssetPicker` --implements--> `BrandAssetPicker`  [EXTRACTED]
  app/lib/features/onboarding/brand_asset_picker_web.dart → app/lib/features/onboarding/brand_asset_picker_types.dart
- `_FakeBrandAssetPicker` --implements--> `BrandAssetPicker`  [EXTRACTED]
  app/test/widget_test.dart → app/lib/features/onboarding/brand_asset_picker_types.dart
- `effectivePlanForUser()` --calls--> `ciDefaultPlanCatalog()`  [INFERRED]
  backend/public/index.php → backend/lib/BackofficePolicy.php
- `publicPlanCatalog()` --calls--> `ciDefaultPlanCatalog()`  [INFERRED]
  backend/public/index.php → backend/lib/BackofficePolicy.php

## Import Cycles
- None detected.

## Communities (55 total, 16 thin omitted)

### Community 0 - "main.dart"
Cohesion: 0.02
Nodes (124): _accountProfile, _accountRepository, active, _add, AppLanguage, assetPicker, _assets, _authCardDecoration (+116 more)

### Community 1 - "legal_page.dart"
Cohesion: 0.05
Nodes (40): BrandFontOption, description, family, sample, standardBrandFonts, BrandTypographySelector, build, font (+32 more)

### Community 2 - "password_reset_pages.dart"
Cohesion: 0.07
Nodes (35): AccountPage, _AccountPageState, build, createState, dispose, _email, _error, _password (+27 more)

### Community 3 - "project_repository.dart"
Cohesion: 0.06
Nodes (30): AccountApiException, BackofficeApiException, BrandAssetPickerException, byteSize, code, company, contentUrl, create (+22 more)

### Community 4 - "account_page.dart"
Cohesion: 0.06
Nodes (31): account_repository.dart, build, _confirmDeletion, createState, csrfToken, _deleting, _formatMegabytes, initState (+23 more)

### Community 5 - "index.php"
Cohesion: 0.10
Nodes (34): ciDefaultPlanCatalog(), auditEvent(), authenticated(), capabilitiesForUser(), createSession(), decryptValue(), effectivePlanForUser(), encryptValue() (+26 more)

### Community 6 - "StatelessWidget"
Cohesion: 0.10
Nodes (20): _AssistantProgress, _AssistantWorkspace, _BrandMark, _ColorSwatch, _Dashboard, _ExplainerCard, _ExternalImageUrlField, _FormLabel (+12 more)

### Community 7 - "legal_document.dart"
Cohesion: 0.12
Nodes (17): body, footerLabel, fromRoute, fromUri, intro, isDraft, label, LegalDocument (+9 more)

### Community 8 - "widget_test.dart"
Cohesion: 0.11
Nodes (17): ensureVisible, enterText, main, _openMaterialStep, pick, pumpAndSettle, requestedKinds, result (+9 more)

### Community 9 - "landing_layout.dart"
Cohesion: 0.12
Nodes (15): @immutable, benefitSpacing, bodySize, compactHeader, eyebrowSize, forWidth, headlineHeight, headlineLetterSpacing (+7 more)

### Community 10 - "cookie_consent.dart"
Cohesion: 0.14
Nodes (14): _acceptNecessary, build, _CookieCategory, CookieConsentBanner, _CookieConsentBannerState, _CookieSettingsSheet, createState, description (+6 more)

### Community 11 - "Daten, Sicherheit und Datenschutz"
Cohesion: 0.15
Nodes (12): Authentifizierung und Rechte, Backoffice, Tarife und Zahlungsdaten, Betriebsschutz, Daten, Sicherheit und Datenschutz, Datenbankentscheidung, Datenschutz by design, Kennwort-Reset, Material: privater Upload oder externe Referenz (+4 more)

### Community 12 - "Michael Gahn DESIGN – CI BUILDER"
Cohesion: 0.17
Nodes (9): Aktueller Produktstand, Datenschutz und Sicherheit, Dokumentation, Michael Gahn DESIGN – CI BUILDER, Aktueller Produktstand, Bereits vorhanden, Datenschutz und Sicherheit, Nächste Schritte (+1 more)

### Community 13 - "brand_asset_picker_types.dart"
Cohesion: 0.18
Nodes (10): BrandAssetKind, BrandAssetSelection, bytes, message, mimeType, name, pick, sizeBytes (+2 more)

### Community 14 - "brand_asset_picker_web.dart"
Cohesion: 0.18
Nodes (10): createBrandAssetPicker, _logoExtensions, _logoLimitBytes, pick, _referenceExtensions, _referenceLimitBytes, dart:async, dart:js_interop (+2 more)

### Community 15 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 16 - "002_projects_manuals_entitlements.sql"
Cohesion: 0.18
Nodes (10): auth_rate_limits, capabilities, manual_documents, media_assets, project_members, project_slot_grants, projects, referral_codes (+2 more)

### Community 17 - "browser_storage_web.dart"
Cohesion: 0.20
Nodes (8): _cookieChoiceKey, hasSavedCookieChoice, openExternalUrl, saveNecessaryCookieChoice, loadDarkModePreference, saveDarkModePreference, _themeModeKey, package:web/web.dart

### Community 18 - "001_identity_security_foundation.sql"
Cohesion: 0.20
Nodes (9): audit_events, auth_one_time_tokens, auth_sessions, roles, schema_migrations, two_factor_methods, two_factor_recovery_codes, user_roles (+1 more)

### Community 19 - "plan_catalog.dart"
Cohesion: 0.06
Nodes (31): fontFamilies, includesAllCoreFeatures, isAvailable, isPaid, logoVariants, megabyte, monthlyPriceCents, name (+23 more)

### Community 20 - "brand_asset_picker_stub.dart"
Cohesion: 0.25
Nodes (6): createBrandAssetPicker, createBrandAssetPicker, pick, _UnsupportedAssetPicker, brand_asset_picker_stub.dart, brand_asset_picker_types.dart

### Community 21 - "Roadmap"
Cohesion: 0.25
Nodes (7): 0.1 — Flutter- und Sicherheitsfundament, 0.2 — Manual-Bibliothek, 0.3 — Veröffentlichung, 0.4 — Agentur-Workflow, 0.5 — optionale Tarife und Store, Nicht Teil des ersten Releases, Roadmap

### Community 22 - "AGENTS.md"
Cohesion: 0.29
Nodes (5): Mission, Source of truth, Verbindliche Regeln, Zuerst lesen, Änderungsablauf

### Community 23 - "Landing-CMS und lokales Designsystem"
Cohesion: 0.29
Nodes (6): Editorregeln, Erscheinungsbilder, Landing-CMS und lokales Designsystem, Sprachen, Ziel, Öffentliche Rechtstexte und Einwilligungen

### Community 24 - "Produktanforderungen — Michael Gahn DESIGN CI BUILDER"
Cohesion: 0.29
Nodes (6): Freemium, Slots und geplante Tarife, Nichtziele für Version 1, Oberflächen, Onboarding-Assistent, Produktanforderungen — Michael Gahn DESIGN CI BUILDER, Produktversprechen

### Community 25 - "[Unreleased]"
Cohesion: 0.33
Nodes (5): Added, Changed, Changelog, Planned, [Unreleased]

### Community 26 - "Architektur"
Cohesion: 0.33
Nodes (5): Architektur, Flutter und URLs, Leitprinzipien, Schichten, Zielarchitektur

### Community 27 - "Lokale Schriftbibliothek und Font-Upload"
Cohesion: 0.33
Nodes (5): Datenschutz und Sicherheit, Einheitliches Schriftmodell, Grundsatz, Kostenpflichtiger Upload, Lokale Schriftbibliothek und Font-Upload

### Community 28 - "Release gates"
Cohesion: 0.33
Nodes (5): Additional gates by risk, Every release, Evidence location, Production rule, Release gates

### Community 29 - "landing-editor.js"
Cohesion: 0.60
Nodes (3): load(), publish(), setState()

### Community 30 - "Inhaltsmodell für professionelle Designmanuals"
Cohesion: 0.40
Nodes (4): Inhaltsmodell für professionelle Designmanuals, Kapitelbibliothek, Regeln statt bloßer Beispiele, Zugänglichkeit als Standard

### Community 31 - "Produktvision"
Cohesion: 0.40
Nodes (4): Für wen, Kernablauf, Nutzenversprechen, Produktvision

### Community 32 - "Security Policy"
Cohesion: 0.40
Nodes (4): Product principles, Scope and maintenance, Security Policy, Vulnerabilities responsibly report

### Community 33 - "browser_storage_stub.dart"
Cohesion: 0.50
Nodes (3): hasSavedCookieChoice, openExternalUrl, saveNecessaryCookieChoice

### Community 34 - "Mitwirken"
Cohesion: 0.50
Nodes (3): Branches, Grundsätze, Mitwirken

### Community 35 - "BrandAssetPicker"
Cohesion: 0.67
Nodes (3): BrandAssetPicker, _WebBrandAssetPicker, _FakeBrandAssetPicker

### Community 51 - "backoffice_repository.dart"
Cohesion: 0.07
Nodes (26): amountCents, BackofficeTransaction, category, createCase, csrfToken, currency, description, fromJson (+18 more)

### Community 52 - "backoffice_page.dart"
Cohesion: 0.09
Nodes (23): ../account/account_repository.dart, BackofficePage, _BackofficePageState, build, _cases, _changeCaseStatus, _createCase, createState (+15 more)

### Community 53 - "007_backoffice_billing_moderation.sql"
Cohesion: 0.33
Nodes (5): account_entitlements, billing_plans, billing_subscriptions, billing_transactions, moderation_cases

## Knowledge Gaps
- **427 isolated node(s):** `csrfToken`, `onChangePassword`, `_deleting`, `_repository`, `_profile` (+422 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 507 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BrandAssetPicker` connect `BrandAssetPicker` to `main.dart`, `brand_asset_picker_stub.dart`, `brand_asset_picker_types.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `AccountProfile` connect `account_page.dart` to `main.dart`, `backoffice_page.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `BrandAssetSelection` connect `brand_asset_picker_types.dart` to `main.dart`, `widget_test.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `csrfToken`, `onChangePassword`, `_deleting` to the rest of the system?**
  _427 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `main.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.016 - nodes in this community are weakly interconnected._
- **Should `legal_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.049494949494949494 - nodes in this community are weakly interconnected._
- **Should `password_reset_pages.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0746031746031746 - nodes in this community are weakly interconnected._