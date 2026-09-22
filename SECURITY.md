# Security Policy

## Vulnerabilities responsibly report

Please do not publish active exploit details, credentials, personal data or
customer manual content in a public issue. Use GitHub private vulnerability
reporting when available, or contact the repository maintainer through an
agreed private channel.

Include the affected component, a minimal reproducible description, the
expected impact and any suggested mitigation. Do not access other users'
data, run denial-of-service tests, attempt credential attacks or make
destructive changes.

## Product principles

The CI BUILDER treats a design manual, its media and its account data as
private customer data. Therefore the implementation follows these principles:

- server-side authorization with roles, capabilities and project membership;
- least privilege and secure defaults;
- no secrets, API keys, private URLs or customer data in Git or the Flutter
  web bundle;
- Argon2id password hashes, hashed one-time tokens and protected sessions;
- MFA for administrators and optional MFA for end users;
- parameterized database access, rate limits, output sanitisation and
  audit events for privileged actions;
- encrypted backups, tested restore procedures and a rollback plan before
  risky migrations or deployments;
- privacy-aware logging: never log passwords, complete tokens, session
  cookies, payment secrets or manual content by default.

## Scope and maintenance

Supported security controls and their operational evidence are documented in
`docs/data-and-security.md` and `docs/release-gates.md`. A reported issue is
assessed privately before a public disclosure or release note is made.

This policy describes the intended engineering process; it is not a legal
guarantee or a substitute for an independent security assessment.
