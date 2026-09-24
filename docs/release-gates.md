# Release gates

This document adapts the MGD Project Platform System's evidence-first release
model to the CI BUILDER. A Git commit is not proof that the live service is
safe, deployed or compliant.

## Every release

1. Review the change and keep its scope small.
2. Run formatter, static analysis and automated tests.
3. Build the Flutter web bundle from a clean dependency install.
   When the build is copied from a NAS or other mounted volume, normalise the
   published file modes after transfer: directories need `755`, static files
   need `644`. Never preserve private `700` modes into the web root; Apache
   denies such files and may return a blanket `403` for the whole app.
4. Verify that no `.env`, credentials, private endpoints, manual files or
   customer media are in the staged Git diff or web bundle.
5. Update affected data-model, security and user-facing documentation.
6. Deploy to staging when the change affects backend, authentication or
   exported output; run a smoke test there.
7. Record the release version, deployed revision, test evidence and rollback
   path before production deployment.
8. Run production smoke tests without using real customer data and monitor
   errors after the release.

## Additional gates by risk

| Change | Required additional evidence |
| --- | --- |
| Database migration | Current backup, dry-run/read check, migration checksum, forward-fix or rollback plan, post-migration check |
| Login, session, MFA or roles | Threat review, rate-limit/lockout checks, authorization tests and privilege-path audit verification |
| Manual/media access or export | Project membership tests, private-object access check, HTML escaping/sanitisation check and PDF/HTML smoke export |
| Privacy or retention behavior | Updated processing/retention documentation, deletion/export test and controller review where required |
| Stripe or entitlements | Test-mode integration, verified webhook signature, idempotency test and no payment secrets in client code |
| Admin action | Explicit confirmation/re-authentication design where high-risk, capability test and audit event verification |

## Production rule

Production is deliberately not deployed by a Git push alone. For a live
change, the responsible person confirms the target, backup/rollback state and
post-deploy checks. Database migrations are forward-compatible where possible;
if a traditional rollback is unsafe, a tested forward-fix is prepared first.

## Evidence location

Operational evidence is never committed when it contains credentials or
personal data. Store it in the approved private operations location and record
only an identifier, timestamp and redacted outcome in release notes.
