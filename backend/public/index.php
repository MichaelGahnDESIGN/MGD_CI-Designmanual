<?php

declare(strict_types=1);

/**
 * Same-origin API entry point for the CI BUILDER Flutter web application.
 * It is dependency-free for shared hosting and intentionally exposes no
 * database credentials or private storage paths to the browser.
 */

$configCandidates = [
    dirname(__DIR__, 2) . '/config.php',
    dirname(__DIR__) . '/config.php',
];
$configPath = null;
foreach ($configCandidates as $candidate) {
    if (is_file($candidate)) {
        $configPath = $candidate;
        break;
    }
}
if ($configPath === null) {
    http_response_code(503);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error' => 'service_not_configured']);
    exit;
}

$config = require $configPath;
// Der Standard liegt bewusst eine Ebene oberhalb der Konfiguration und damit
// außerhalb des API-/Webordners. Eine explizite Serverkonfiguration kann ihn
// bei abweichendem Hosting überschreiben.
$config['storage']['media_root'] ??= dirname(dirname($configPath)) . '/private-media';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: no-referrer');

function respond(int $status, array $payload): never {
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function requestBody(): array {
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        return [];
    }
    $value = json_decode($raw, true);
    if (!is_array($value)) {
        respond(400, ['error' => 'invalid_json']);
    }
    return $value;
}

function text(array $body, string $key, int $max = 4096): string {
    $value = $body[$key] ?? '';
    if (!is_string($value)) {
        respond(422, ['error' => 'invalid_input']);
    }
    $value = trim($value);
    if (mb_strlen($value) > $max) {
        respond(422, ['error' => 'invalid_input']);
    }
    return $value;
}

function validPassword(string $value): bool {
    return strlen($value) >= 14
        && preg_match('/[A-Z]/', $value)
        && preg_match('/[a-z]/', $value)
        && preg_match('/[0-9]/', $value);
}

function validUsername(string $value): bool {
    return (bool) preg_match('/^[A-Za-z0-9][A-Za-z0-9._-]{2,39}$/', $value);
}

/**
 * Externe Bilder werden ausschließlich im Browser der Person geladen.
 *
 * Der Server speichert nur eine verschlüsselte HTTPS-Adresse und ruft sie nie
 * selbst ab. Damit gibt es keinen Proxy, keine serverseitige Bildanalyse und
 * kein SSRF-Risiko. Benutzername/Kennwort in einer URL sind nicht erlaubt.
 */
function externalImageUrl(string $value): string {
    if ($value === '') return '';
    if (strlen($value) > 2048 || preg_match('/[\x00-\x1F\x7F]/', $value)) {
        respond(422, ['error' => 'invalid_external_image_url']);
    }
    $parts = parse_url($value);
    if (!is_array($parts)
        || ($parts['scheme'] ?? '') !== 'https'
        || !is_string($parts['host'] ?? null)
        || $parts['host'] === ''
        || isset($parts['user'])
        || isset($parts['pass'])) {
        respond(422, ['error' => 'invalid_external_image_url']);
    }
    return $value;
}

/**
 * Liefert ausschließlich eine konfigurierte HTTPS-Adresse für Einmal-Links.
 * Der Token wird URL-kodiert und nie in Logs oder API-Antworten ausgegeben.
 */
function passwordResetUrl(array $config, string $token): string {
    $base = (string) ($config['app']['public_base_url'] ?? 'https://ci.michael-gahn.de');
    if (!filter_var($base, FILTER_VALIDATE_URL) || !str_starts_with($base, 'https://')) {
        throw new RuntimeException('Invalid public base URL');
    }
    return rtrim($base, '/') . '/?reset=' . rawurlencode($token);
}

/**
 * E-Mail ist bewusst nur ein Transportweg. Die Entscheidung, ob ein Konto
 * existiert, wird niemals an den Browser zurückgegeben.
 */
function sendPasswordResetMail(array $config, string $recipient, string $token): bool {
    $from = (string) ($config['mail']['from'] ?? 'no-reply@ci.michael-gahn.de');
    if (!filter_var($recipient, FILTER_VALIDATE_EMAIL) || !filter_var($from, FILTER_VALIDATE_EMAIL)) {
        return false;
    }
    $url = passwordResetUrl($config, $token);
    $subject = 'CI BUILDER – Kennwort zurücksetzen';
    $message = "Hallo,\n\n" .
        "für dein CI BUILDER Konto wurde ein Kennwort-Reset angefordert.\n" .
        "Öffne innerhalb von 30 Minuten diesen Link:\n" . $url . "\n\n" .
        "Falls du diese Anfrage nicht gestellt hast, kannst du diese E-Mail ignorieren.\n";
    $headers = "From: CI BUILDER <{$from}>\r\n" .
        "Content-Type: text/plain; charset=UTF-8\r\n" .
        "X-Content-Type-Options: nosniff";
    return function_exists('mail') && @mail($recipient, $subject, $message, $headers);
}

function requestIp(): string {
    return (string) ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
}

/** Records only an HMAC pseudonym, never an address or identity in cleartext. */
function enforceRateLimit(PDO $pdo, array $config, string $scope, string $subject, int $limit, int $minutes): void {
    $hash = lookupHash($config, $scope . ':' . $subject);
    $cleanup = $pdo->prepare('DELETE FROM auth_rate_limit_events WHERE created_at < DATE_SUB(UTC_TIMESTAMP(6), INTERVAL 1 DAY) LIMIT 500');
    $cleanup->execute();
    $count = $pdo->prepare('SELECT COUNT(*) FROM auth_rate_limit_events WHERE scope = ? AND subject_hash = ? AND created_at >= DATE_SUB(UTC_TIMESTAMP(6), INTERVAL ? MINUTE)');
    $count->execute([$scope, $hash, $minutes]);
    if ((int) $count->fetchColumn() >= $limit) {
        respond(429, ['error' => 'rate_limited']);
    }
    $insert = $pdo->prepare('INSERT INTO auth_rate_limit_events (id, scope, subject_hash) VALUES (?, ?, ?)');
    $insert->execute([uuidV7(), $scope, $hash]);
}

function localeValue(string $value): string {
    $value = strtolower(trim($value));
    if (!in_array($value, ['de', 'en'], true)) {
        respond(422, ['error' => 'unsupported_locale']);
    }
    return $value;
}

function keyBytes(array $config, string $name): string {
    $key = base64_decode((string) ($config['crypto'][$name] ?? ''), true);
    if ($key === false || strlen($key) !== 32) {
        throw new RuntimeException('Invalid key configuration');
    }
    return $key;
}

function lookupHash(array $config, string $value): string {
    return hash_hmac('sha256', mb_strtolower(trim($value)), keyBytes($config, 'lookup_key_b64'), true);
}

function encryptValue(array $config, string $value): array {
    $nonce = random_bytes(12);
    $tag = '';
    $ciphertext = openssl_encrypt($value, 'aes-256-gcm', keyBytes($config, 'data_key_b64'), OPENSSL_RAW_DATA, $nonce, $tag, 'mgd-ci-builder:v1');
    if ($ciphertext === false || strlen($tag) !== 16) {
        throw new RuntimeException('Encryption failed');
    }
    return [$ciphertext, $nonce, $tag];
}

function decryptValue(array $config, string $ciphertext, string $nonce, string $tag): string {
    $value = openssl_decrypt($ciphertext, 'aes-256-gcm', keyBytes($config, 'data_key_b64'), OPENSSL_RAW_DATA, $nonce, $tag, 'mgd-ci-builder:v1');
    if (!is_string($value)) {
        throw new RuntimeException('Decryption failed');
    }
    return $value;
}

function uuidV7(): string {
    $time = str_pad(dechex((int) floor(microtime(true) * 1000)), 12, '0', STR_PAD_LEFT);
    $random = bin2hex(random_bytes(10));
    $variant = str_pad(dechex((hexdec(substr($random, 3, 2)) & 0x3f) | 0x80), 2, '0', STR_PAD_LEFT);
    return hex2bin($time . '7' . substr($random, 0, 3) . $variant . substr($random, 5, 14));
}

function uuidText(string $binary): string {
    $hex = bin2hex($binary);
    return substr($hex, 0, 8) . '-' . substr($hex, 8, 4) . '-' . substr($hex, 12, 4) . '-' . substr($hex, 16, 4) . '-' . substr($hex, 20);
}

/** Wandelt eine öffentliche UUID sicher in das binäre Datenbankformat um. */
function uuidBinary(string $value): string {
    $value = strtolower(trim($value));
    if (!preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/', $value)) {
        respond(422, ['error' => 'invalid_identifier']);
    }
    $binary = hex2bin(str_replace('-', '', $value));
    if ($binary === false) respond(422, ['error' => 'invalid_identifier']);
    return $binary;
}

/**
 * Prüft die Projektmitgliedschaft unmittelbar vor jedem Medienzugriff.
 * Die Tabellenprüfung ist die Berechtigungsgrenze; der Client liefert keine
 * vertrauenswürdige Nutzer- oder Speicherinformation.
 */
function requireProjectAccess(PDO $pdo, array $session, string $projectId, bool $write = false): array {
    $statement = $pdo->prepare('SELECT p.id, pm.membership_role FROM projects p JOIN project_members pm ON pm.project_id = p.id WHERE p.id = ? AND pm.user_id = ? AND p.status != \'deleted\' LIMIT 1');
    $statement->execute([$projectId, $session['user_id']]);
    $project = $statement->fetch();
    if (!$project || ($write && !in_array($project['membership_role'], ['owner', 'editor'], true))) {
        respond(403, ['error' => 'forbidden']);
    }
    return $project;
}

/** Privater Speicher liegt zwingend außerhalb des Webroots. */
function mediaStorageRoot(array $config): string {
    $root = (string) ($config['storage']['media_root'] ?? '');
    if ($root === '' || str_contains($root, "\0")) throw new RuntimeException('Invalid media storage configuration');
    if (!is_dir($root) && !mkdir($root, 0700, true) && !is_dir($root)) {
        throw new RuntimeException('Private media storage unavailable');
    }
    return realpath($root) ?: throw new RuntimeException('Private media storage unavailable');
}

/** Serverseitige Inhaltsprüfung; Client-MIME und Dateiendung sind nicht vertrauenswürdig. */
function validatedImageUpload(array $file): array {
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK || !isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
        respond(422, ['error' => 'invalid_upload']);
    }
    $size = (int) ($file['size'] ?? 0);
    if ($size < 1 || $size > 10 * 1024 * 1024) respond(422, ['error' => 'invalid_upload']);
    $image = @getimagesize($file['tmp_name']);
    if (!is_array($image) || !isset($image['mime'], $image[0], $image[1]) || $image[0] > 8000 || $image[1] > 8000) {
        respond(422, ['error' => 'invalid_upload']);
    }
    $mime = $image['mime'];
    $extensions = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    if (!isset($extensions[$mime])) respond(422, ['error' => 'invalid_upload']);
    return [$mime, $extensions[$mime], $size];
}

function pdo(array $config): PDO {
    $db = $config['database'];
    return new PDO(
        sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $db['host'], $db['port'], $db['name']),
        $db['user'],
        $db['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC],
    );
}

function authenticated(PDO $pdo, array $config): array {
    $cookieName = $config['session']['cookie_name'];
    $token = $_COOKIE[$cookieName] ?? null;
    if (!is_string($token) || strlen($token) !== 64 || !ctype_xdigit($token)) {
        respond(401, ['error' => 'unauthenticated']);
    }
    $statement = $pdo->prepare('SELECT s.id AS session_id, s.csrf_token_hash, u.id AS user_id, u.username_ciphertext, u.username_key_version, u.must_change_password FROM auth_sessions s JOIN users u ON u.id = s.user_id WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > UTC_TIMESTAMP(6) AND u.status = \'active\' LIMIT 1');
    $statement->execute([hash('sha256', $token, true)]);
    $session = $statement->fetch();
    if (!$session) {
        respond(401, ['error' => 'unauthenticated']);
    }
    return $session;
}

function requireCsrf(array $session): void {
    $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    $cookie = $_COOKIE['ci_builder_csrf'] ?? '';
    if (!is_string($token) || !is_string($cookie) || !hash_equals($cookie, $token) || !hash_equals($session['csrf_token_hash'], hash('sha256', $token, true))) {
        respond(403, ['error' => 'csrf_failed']);
    }
}

function hasCapability(PDO $pdo, string $userId, string $capability): bool {
    $statement = $pdo->prepare('SELECT 1 FROM user_roles ur JOIN role_capabilities rc ON rc.role_id = ur.role_id JOIN capabilities c ON c.id = rc.capability_id WHERE ur.user_id = ? AND c.`key` = ? LIMIT 1');
    $statement->execute([$userId, $capability]);
    return (bool) $statement->fetchColumn();
}

function requireCapability(PDO $pdo, array $session, string $capability): void {
    if (!hasCapability($pdo, $session['user_id'], $capability)) {
        respond(403, ['error' => 'forbidden']);
    }
}

function createSession(PDO $pdo, array $config, string $userId): array {
    $token = bin2hex(random_bytes(32));
    $csrf = bin2hex(random_bytes(32));
    $ttl = (int) $config['session']['ttl_seconds'];
    $statement = $pdo->prepare('INSERT INTO auth_sessions (id, user_id, token_hash, csrf_token_hash, ip_hash, user_agent_hash, expires_at) VALUES (?, ?, ?, ?, ?, ?, DATE_ADD(UTC_TIMESTAMP(6), INTERVAL ? SECOND))');
    $statement->execute([uuidV7(), $userId, hash('sha256', $token, true), hash('sha256', $csrf, true), hash('sha256', $_SERVER['REMOTE_ADDR'] ?? '', true), hash('sha256', $_SERVER['HTTP_USER_AGENT'] ?? '', true), $ttl]);
    $options = ['expires' => time() + $ttl, 'path' => '/', 'secure' => true, 'httponly' => true, 'samesite' => 'Strict'];
    setcookie($config['session']['cookie_name'], $token, $options);
    setcookie('ci_builder_csrf', $csrf, [...$options, 'httponly' => false]);
    return ['csrf_token' => $csrf];
}

set_exception_handler(static function (Throwable $error): never {
    error_log('CI BUILDER API failure: ' . $error->getMessage());
    respond(500, ['error' => 'server_error']);
});

$pdo = pdo($config);
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$path = preg_replace('#^/api#', '', $path) ?: '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET' && $path === '/health') {
    $pdo->query('SELECT 1');
    respond(200, ['status' => 'ok']);
}

if ($method === 'POST' && $path === '/auth/register') {
    $body = requestBody();
    $username = text($body, 'username', 40);
    $email = text($body, 'email', 254);
    $password = text($body, 'password', 1024);
    enforceRateLimit($pdo, $config, 'register-ip', requestIp(), 5, 15);
    if (!validUsername($username) || !filter_var($email, FILTER_VALIDATE_EMAIL) || !validPassword($password)) {
        respond(422, ['error' => 'invalid_registration']);
    }
    $usernameHash = lookupHash($config, $username);
    $emailHash = lookupHash($config, $email);
    [$usernameCiphertext, $usernameNonce, $usernameTag] = encryptValue($config, $username);
    [$emailCiphertext, $emailNonce, $emailTag] = encryptValue($config, $email);
    $pdo->beginTransaction();
    try {
        $exists = $pdo->prepare('SELECT 1 FROM users WHERE username_lookup_hash = ? OR email_lookup_hash = ? LIMIT 1');
        $exists->execute([$usernameHash, $emailHash]);
        if ($exists->fetchColumn()) {
            $pdo->rollBack();
            respond(409, ['error' => 'registration_unavailable']);
        }
        $userId = uuidV7();
        $insert = $pdo->prepare("INSERT INTO users (id, email_lookup_hash, username_lookup_hash, username_ciphertext, username_nonce, username_auth_tag, username_key_version, email_ciphertext, email_nonce, email_auth_tag, email_key_version, password_hash, email_verified_at, status, must_change_password) VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, ?, 1, ?, UTC_TIMESTAMP(6), 'active', 0)");
        $insert->execute([$userId, $emailHash, $usernameHash, $usernameCiphertext, $usernameNonce, $usernameTag, $emailCiphertext, $emailNonce, $emailTag, password_hash($password, PASSWORD_ARGON2ID)]);
        $role = $pdo->query("SELECT id FROM roles WHERE slug = 'member' LIMIT 1")->fetchColumn();
        $pdo->prepare('INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)')->execute([$userId, $role]);
        $pdo->prepare("INSERT INTO project_slot_grants (id, user_id, source) VALUES (?, ?, 'free')")->execute([uuidV7(), $userId]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    respond(201, ['status' => 'registered']);
}

if ($method === 'GET' && $path === '/cms/landing') {
    $locale = localeValue((string) ($_GET['locale'] ?? 'de'));
    $statement = $pdo->prepare('SELECT content_ciphertext, content_nonce, content_auth_tag, revision_no FROM cms_landing_pages WHERE locale = ? AND status = \'published\' LIMIT 1');
    $statement->execute([$locale]);
    $content = $statement->fetch();
    if (!$content) {
        respond(404, ['error' => 'content_not_found']);
    }
    $decoded = json_decode(decryptValue($config, $content['content_ciphertext'], $content['content_nonce'], $content['content_auth_tag']), true);
    if (!is_array($decoded)) {
        respond(500, ['error' => 'invalid_content']);
    }
    respond(200, ['locale' => $locale, 'revision' => (int) $content['revision_no'], 'content' => $decoded]);
}

if ($method === 'POST' && $path === '/auth/login') {
    $body = requestBody();
    $identity = text($body, 'identity', 254);
    $password = text($body, 'password', 1024);
    if ($identity === '' || $password === '') {
        respond(422, ['error' => 'invalid_credentials']);
    }
    $hash = lookupHash($config, $identity);
    $statement = $pdo->prepare('SELECT id, password_hash, must_change_password, username_ciphertext, username_nonce, username_auth_tag FROM users WHERE (username_lookup_hash = ? OR email_lookup_hash = ?) AND status = \'active\' LIMIT 1');
    $statement->execute([$hash, $hash]);
    $user = $statement->fetch();
    if (!$user || !password_verify($password, $user['password_hash'])) {
        usleep(250000);
        respond(401, ['error' => 'invalid_credentials']);
    }
    if (password_needs_rehash($user['password_hash'], PASSWORD_ARGON2ID)) {
        $pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([password_hash($password, PASSWORD_ARGON2ID), $user['id']]);
    }
    $session = createSession($pdo, $config, $user['id']);
    $pdo->prepare('UPDATE users SET last_login_at = UTC_TIMESTAMP(6) WHERE id = ?')->execute([$user['id']]);
    respond(200, [...$session, 'user' => ['id' => uuidText($user['id']), 'username' => decryptValue($config, $user['username_ciphertext'], $user['username_nonce'], $user['username_auth_tag']), 'must_change_password' => (bool) $user['must_change_password']]]);
}

if ($method === 'POST' && $path === '/auth/logout') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $pdo->prepare('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP(6) WHERE id = ?')->execute([$session['session_id']]);
    setcookie($config['session']['cookie_name'], '', ['expires' => 1, 'path' => '/', 'secure' => true, 'httponly' => true, 'samesite' => 'Strict']);
    setcookie('ci_builder_csrf', '', ['expires' => 1, 'path' => '/', 'secure' => true, 'httponly' => false, 'samesite' => 'Strict']);
    respond(204, []);
}

if ($method === 'GET' && $path === '/auth/me') {
    $session = authenticated($pdo, $config);
    $profile = $pdo->prepare('SELECT username_ciphertext, username_nonce, username_auth_tag, email_ciphertext, email_nonce, email_auth_tag FROM users WHERE id = ? LIMIT 1');
    $profile->execute([$session['user_id']]);
    $profileData = $profile->fetch();
    if (!$profileData) respond(401, ['error' => 'unauthenticated']);

    // Der Plan wird bis zur Stripe-Anbindung bewusst serverseitig als
    // Freemium-Entitlement berechnet. Der Client darf nie Slots ableiten.
    $slotStatement = $pdo->prepare('SELECT COUNT(*) FROM project_slot_grants WHERE user_id = ? AND revoked_at IS NULL');
    $slotStatement->execute([$session['user_id']]);
    $slotsTotal = (int) $slotStatement->fetchColumn();
    $projectStatement = $pdo->prepare("SELECT COUNT(*) FROM projects WHERE owner_user_id = ? AND status != 'deleted'");
    $projectStatement->execute([$session['user_id']]);
    $projectsUsed = (int) $projectStatement->fetchColumn();
    $storageStatement = $pdo->prepare("SELECT COALESCE(SUM(ma.byte_size), 0) FROM media_assets ma JOIN projects p ON p.id = ma.project_id WHERE p.owner_user_id = ? AND p.status != 'deleted' AND ma.deleted_at IS NULL");
    $storageStatement->execute([$session['user_id']]);
    $storageUsed = (int) $storageStatement->fetchColumn();
    respond(200, [
        'user' => [
            'id' => uuidText($session['user_id']),
            'username' => decryptValue($config, $profileData['username_ciphertext'], $profileData['username_nonce'], $profileData['username_auth_tag']),
            'email' => decryptValue($config, $profileData['email_ciphertext'], $profileData['email_nonce'], $profileData['email_auth_tag']),
            'must_change_password' => (bool) $session['must_change_password'],
        ],
        'plan' => [
            'key' => 'free',
            'label' => 'Kostenlos',
            'projects_used' => $projectsUsed,
            'projects_total' => $slotsTotal,
            // Ein Slot umfasst derzeit 100 MB privaten Medien-Speicher.
            'storage_used_bytes' => $storageUsed,
            'storage_total_bytes' => max($slotsTotal, 1) * 100 * 1024 * 1024,
        ],
    ]);
}

if ($method === 'POST' && $path === '/auth/change-password') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $body = requestBody();
    $current = text($body, 'current_password', 1024);
    $next = text($body, 'new_password', 1024);
    if (!validPassword($next)) {
        respond(422, ['error' => 'weak_password']);
    }
    $statement = $pdo->prepare('SELECT password_hash FROM users WHERE id = ?');
    $statement->execute([$session['user_id']]);
    $user = $statement->fetch();
    if (!$user || !password_verify($current, $user['password_hash'])) {
        respond(401, ['error' => 'invalid_credentials']);
    }
    $pdo->prepare('UPDATE users SET password_hash = ?, password_changed_at = UTC_TIMESTAMP(6), must_change_password = 0 WHERE id = ?')->execute([password_hash($next, PASSWORD_ARGON2ID), $session['user_id']]);
    respond(200, ['status' => 'password_changed']);
}

if ($method === 'POST' && $path === '/auth/request-password-reset') {
    $body = requestBody();
    $email = text($body, 'email', 320);
    // Rate-Limits schützen unabhängig vom Kontostatus vor Missbrauch.
    enforceRateLimit($pdo, $config, 'password-reset-ip', requestIp(), 3, 15);
    if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
        enforceRateLimit($pdo, $config, 'password-reset-email', $email, 3, 30);
        $statement = $pdo->prepare("SELECT id, email_ciphertext, email_nonce, email_auth_tag FROM users WHERE email_lookup_hash = ? AND status = 'active' LIMIT 1");
        $statement->execute([lookupHash($config, $email)]);
        $user = $statement->fetch();
        if ($user) {
            $token = bin2hex(random_bytes(32));
            $tokenHash = lookupHash($config, $token);
            $pdo->beginTransaction();
            try {
                // Pro Konto ist nur der zuletzt ausgestellte Link gültig.
                $pdo->prepare("UPDATE auth_one_time_tokens SET consumed_at = UTC_TIMESTAMP(6) WHERE user_id = ? AND purpose = 'password_reset' AND consumed_at IS NULL")
                    ->execute([$user['id']]);
                $insert = $pdo->prepare("INSERT INTO auth_one_time_tokens (id, user_id, purpose, token_hash, expires_at) VALUES (?, ?, 'password_reset', ?, DATE_ADD(UTC_TIMESTAMP(6), INTERVAL 30 MINUTE))");
                $insert->execute([uuidV7(), $user['id'], $tokenHash]);
                $recipient = decryptValue($config, $user['email_ciphertext'], $user['email_nonce'], $user['email_auth_tag']);
                if (!sendPasswordResetMail($config, $recipient, $token)) {
                    throw new RuntimeException('Password reset mail unavailable');
                }
                $pdo->commit();
            } catch (Throwable $error) {
                if ($pdo->inTransaction()) $pdo->rollBack();
                // Die API bleibt absichtlich generisch, damit kein Kontostatus
                // oder Mail-Transportdetail als Information preisgegeben wird.
            }
        }
    }
    respond(202, ['status' => 'password_reset_requested']);
}

if ($method === 'POST' && $path === '/auth/reset-password') {
    $body = requestBody();
    $token = text($body, 'token', 128);
    $next = text($body, 'new_password', 1024);
    enforceRateLimit($pdo, $config, 'password-reset-confirm-ip', requestIp(), 8, 15);
    if (!preg_match('/^[a-f0-9]{64}$/', $token) || !validPassword($next)) {
        respond(422, ['error' => 'invalid_reset']);
    }
    $pdo->beginTransaction();
    try {
        $statement = $pdo->prepare("SELECT id, user_id FROM auth_one_time_tokens WHERE purpose = 'password_reset' AND token_hash = ? AND consumed_at IS NULL AND expires_at > UTC_TIMESTAMP(6) LIMIT 1 FOR UPDATE");
        $statement->execute([lookupHash($config, $token)]);
        $reset = $statement->fetch();
        if (!$reset) {
            $pdo->rollBack();
            respond(422, ['error' => 'invalid_reset']);
        }
        $pdo->prepare('UPDATE users SET password_hash = ?, password_changed_at = UTC_TIMESTAMP(6), must_change_password = 0 WHERE id = ?')
            ->execute([password_hash($next, PASSWORD_ARGON2ID), $reset['user_id']]);
        $pdo->prepare('UPDATE auth_one_time_tokens SET consumed_at = UTC_TIMESTAMP(6) WHERE id = ?')
            ->execute([$reset['id']]);
        // Ein Reset beendet alle existierenden Sitzungen; neue Anmeldung ist nötig.
        $pdo->prepare('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP(6) WHERE user_id = ? AND revoked_at IS NULL')
            ->execute([$reset['user_id']]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    respond(200, ['status' => 'password_reset']);
}

if ($method === 'POST' && $path === '/auth/delete-account') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $body = requestBody();
    $password = text($body, 'password', 1024);
    if (text($body, 'confirmation', 16) !== 'DELETE') {
        respond(422, ['error' => 'invalid_confirmation']);
    }
    $statement = $pdo->prepare('SELECT password_hash FROM users WHERE id = ? LIMIT 1');
    $statement->execute([$session['user_id']]);
    $hash = $statement->fetchColumn();
    if (!is_string($hash) || !password_verify($password, $hash)) {
        respond(401, ['error' => 'invalid_credentials']);
    }
    $pdo->beginTransaction();
    try {
        // Die Datenbank löscht Medienmetadaten per Cascade. Die privaten Dateien
        // entfernen wir anschließend anhand der zuvor autorisiert gelesenen Keys.
        $media = $pdo->prepare('SELECT ma.storage_key_ciphertext, ma.storage_key_nonce, ma.storage_key_auth_tag FROM media_assets ma JOIN projects p ON p.id = ma.project_id WHERE p.owner_user_id = ? AND ma.deleted_at IS NULL');
        $media->execute([$session['user_id']]);
        $storageKeys = [];
        foreach ($media as $asset) {
            $storageKeys[] = decryptValue($config, $asset['storage_key_ciphertext'], $asset['storage_key_nonce'], $asset['storage_key_auth_tag']);
        }
        $pdo->prepare('DELETE FROM projects WHERE owner_user_id = ?')->execute([$session['user_id']]);
        $deleted = $pdo->prepare('DELETE FROM users WHERE id = ?');
        $deleted->execute([$session['user_id']]);
        if ($deleted->rowCount() !== 1) throw new RuntimeException('Account delete failed');
        $pdo->commit();
        $root = mediaStorageRoot($config);
        foreach ($storageKeys as $storageKey) {
            if (preg_match('/^[a-f0-9]{48}\.(jpg|png|webp)$/', $storageKey)) @unlink($root . DIRECTORY_SEPARATOR . $storageKey);
        }
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    setcookie($config['session']['cookie_name'], '', ['expires' => 1, 'path' => '/', 'secure' => true, 'httponly' => true, 'samesite' => 'Strict']);
    setcookie('ci_builder_csrf', '', ['expires' => 1, 'path' => '/', 'secure' => true, 'httponly' => false, 'samesite' => 'Strict']);
    respond(204, []);
}

if ($method === 'GET' && $path === '/projects') {
    $session = authenticated($pdo, $config);
    $statement = $pdo->prepare("SELECT id, name_ciphertext, name_nonce, name_auth_tag, company_ciphertext, company_nonce, company_auth_tag, logo_external_url_ciphertext, logo_external_url_nonce, logo_external_url_auth_tag, reference_image_external_url_ciphertext, reference_image_external_url_nonce, reference_image_external_url_auth_tag, font_family, created_at FROM projects WHERE owner_user_id = ? AND status != 'deleted' ORDER BY created_at DESC");
    $statement->execute([$session['user_id']]);
    $projects = [];
    foreach ($statement as $row) {
        $projects[] = [
            'id' => uuidText($row['id']),
            'name' => decryptValue($config, $row['name_ciphertext'], $row['name_nonce'], $row['name_auth_tag']),
            'company' => $row['company_ciphertext'] === null ? null : decryptValue($config, $row['company_ciphertext'], $row['company_nonce'], $row['company_auth_tag']),
            'logo_external_url' => $row['logo_external_url_ciphertext'] === null ? null : decryptValue($config, $row['logo_external_url_ciphertext'], $row['logo_external_url_nonce'], $row['logo_external_url_auth_tag']),
            'reference_image_external_url' => $row['reference_image_external_url_ciphertext'] === null ? null : decryptValue($config, $row['reference_image_external_url_ciphertext'], $row['reference_image_external_url_nonce'], $row['reference_image_external_url_auth_tag']),
            'font_family' => $row['font_family'],
            'created_at' => $row['created_at'],
        ];
    }
    respond(200, ['projects' => $projects]);
}

if ($method === 'POST' && $path === '/projects') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $body = requestBody();
    $name = text($body, 'name', 160);
    $company = text($body, 'company', 160);
    $description = text($body, 'description', 2000);
    $fontFamily = text($body, 'font_family', 80);
    $logoExternalUrl = externalImageUrl(text($body, 'logo_external_url', 2048));
    $referenceImageExternalUrl = externalImageUrl(text($body, 'reference_image_external_url', 2048));
    if ($name === '' || !in_array($fontFamily, ['Open Sans', 'Lato', 'Montserrat', 'Merriweather'], true)) {
        respond(422, ['error' => 'invalid_project']);
    }
    $slots = $pdo->prepare("SELECT (SELECT COUNT(*) FROM project_slot_grants WHERE user_id = ? AND revoked_at IS NULL) - (SELECT COUNT(*) FROM projects WHERE owner_user_id = ? AND status != 'deleted')");
    $slots->execute([$session['user_id'], $session['user_id']]);
    if ((int) $slots->fetchColumn() < 1) respond(403, ['error' => 'project_slot_limit']);
    [$nameCiphertext, $nameNonce, $nameTag] = encryptValue($config, $name);
    [$companyCiphertext, $companyNonce, $companyTag] = encryptValue($config, $company);
    [$descriptionCiphertext, $descriptionNonce, $descriptionTag] = encryptValue($config, $description);
    [$logoUrlCiphertext, $logoUrlNonce, $logoUrlTag] = $logoExternalUrl === '' ? [null, null, null] : encryptValue($config, $logoExternalUrl);
    [$referenceUrlCiphertext, $referenceUrlNonce, $referenceUrlTag] = $referenceImageExternalUrl === '' ? [null, null, null] : encryptValue($config, $referenceImageExternalUrl);
    $projectId = uuidV7();
    $pdo->beginTransaction();
    try {
        $insert = $pdo->prepare("INSERT INTO projects (id, owner_user_id, name_ciphertext, name_nonce, name_auth_tag, company_ciphertext, company_nonce, company_auth_tag, description_ciphertext, description_nonce, description_auth_tag, logo_external_url_ciphertext, logo_external_url_nonce, logo_external_url_auth_tag, reference_image_external_url_ciphertext, reference_image_external_url_nonce, reference_image_external_url_auth_tag, font_family) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $insert->execute([$projectId, $session['user_id'], $nameCiphertext, $nameNonce, $nameTag, $companyCiphertext, $companyNonce, $companyTag, $descriptionCiphertext, $descriptionNonce, $descriptionTag, $logoUrlCiphertext, $logoUrlNonce, $logoUrlTag, $referenceUrlCiphertext, $referenceUrlNonce, $referenceUrlTag, $fontFamily]);
        $pdo->prepare("INSERT INTO project_members (project_id, user_id, membership_role) VALUES (?, ?, 'owner')")->execute([$projectId, $session['user_id']]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    respond(201, ['project' => ['id' => uuidText($projectId), 'name' => $name, 'company' => $company === '' ? null : $company, 'logo_external_url' => $logoExternalUrl === '' ? null : $logoExternalUrl, 'reference_image_external_url' => $referenceImageExternalUrl === '' ? null : $referenceImageExternalUrl, 'font_family' => $fontFamily, 'created_at' => gmdate('c')]]);
}

if (preg_match('#^/projects/([0-9a-f-]{36})/media$#i', $path, $matches) && $method === 'GET') {
    $session = authenticated($pdo, $config);
    $projectId = uuidBinary($matches[1]);
    requireProjectAccess($pdo, $session, $projectId);
    $statement = $pdo->prepare('SELECT id, media_kind, mime_type, byte_size, created_at FROM media_assets WHERE project_id = ? AND deleted_at IS NULL ORDER BY created_at DESC');
    $statement->execute([$projectId]);
    $assets = [];
    foreach ($statement as $asset) {
        $assetId = uuidText($asset['id']);
        $assets[] = [
            'id' => $assetId,
            'kind' => $asset['media_kind'],
            'mime_type' => $asset['mime_type'],
            'byte_size' => (int) $asset['byte_size'],
            'created_at' => $asset['created_at'],
            // Keine Storage-Keys oder Dateinamen: nur ein kontrollierter API-Endpunkt.
            'content_url' => '/api/projects/' . $matches[1] . '/media/' . $assetId,
        ];
    }
    respond(200, ['assets' => $assets]);
}

if (preg_match('#^/projects/([0-9a-f-]{36})/media$#i', $path, $matches) && $method === 'POST') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $projectId = uuidBinary($matches[1]);
    requireProjectAccess($pdo, $session, $projectId, true);
    $kind = $_POST['kind'] ?? '';
    if (!is_string($kind) || !in_array($kind, ['logo', 'reference_image', 'manual_image'], true) || count($_FILES) !== 1 || !isset($_FILES['file']) || !is_array($_FILES['file'])) {
        respond(422, ['error' => 'invalid_upload']);
    }
    [$mime, $extension, $size] = validatedImageUpload($_FILES['file']);
    $quota = $pdo->prepare('SELECT COALESCE(SUM(byte_size), 0) FROM media_assets WHERE project_id = ? AND deleted_at IS NULL');
    $quota->execute([$projectId]);
    if ((int) $quota->fetchColumn() + $size > 100 * 1024 * 1024) respond(422, ['error' => 'project_media_quota_exceeded']);
    $storageKey = bin2hex(random_bytes(24)) . '.' . $extension;
    $destination = mediaStorageRoot($config) . DIRECTORY_SEPARATOR . $storageKey;
    if (!move_uploaded_file($_FILES['file']['tmp_name'], $destination)) throw new RuntimeException('Upload move failed');
    @chmod($destination, 0600);
    $assetId = uuidV7();
    [$keyCiphertext, $keyNonce, $keyTag] = encryptValue($config, $storageKey);
    $originalName = text(['name' => (string) ($_FILES['file']['name'] ?? '')], 'name', 255);
    [$nameCiphertext, $nameNonce, $nameTag] = encryptValue($config, $originalName);
    try {
        $insert = $pdo->prepare('INSERT INTO media_assets (id, project_id, storage_key_ciphertext, storage_key_nonce, storage_key_auth_tag, original_name_ciphertext, original_name_nonce, original_name_auth_tag, media_kind, mime_type, byte_size, sha256, created_by_user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $insert->execute([$assetId, $projectId, $keyCiphertext, $keyNonce, $keyTag, $nameCiphertext, $nameNonce, $nameTag, $kind, $mime, $size, hash_file('sha256', $destination, true), $session['user_id']]);
    } catch (Throwable $error) {
        @unlink($destination);
        throw $error;
    }
    respond(201, ['asset' => ['id' => uuidText($assetId), 'kind' => $kind, 'mime_type' => $mime, 'byte_size' => $size, 'content_url' => '/api/projects/' . $matches[1] . '/media/' . uuidText($assetId)]]);
}

if (preg_match('#^/projects/([0-9a-f-]{36})/media/([0-9a-f-]{36})$#i', $path, $matches) && $method === 'GET') {
    $session = authenticated($pdo, $config);
    $projectId = uuidBinary($matches[1]);
    $assetId = uuidBinary($matches[2]);
    requireProjectAccess($pdo, $session, $projectId);
    $statement = $pdo->prepare('SELECT storage_key_ciphertext, storage_key_nonce, storage_key_auth_tag, mime_type, byte_size FROM media_assets WHERE id = ? AND project_id = ? AND deleted_at IS NULL LIMIT 1');
    $statement->execute([$assetId, $projectId]);
    $asset = $statement->fetch();
    if (!$asset) respond(404, ['error' => 'not_found']);
    $storageKey = decryptValue($config, $asset['storage_key_ciphertext'], $asset['storage_key_nonce'], $asset['storage_key_auth_tag']);
    if (!preg_match('/^[a-f0-9]{48}\.(jpg|png|webp)$/', $storageKey)) throw new RuntimeException('Invalid storage key');
    $file = mediaStorageRoot($config) . DIRECTORY_SEPARATOR . $storageKey;
    if (!is_file($file)) respond(404, ['error' => 'not_found']);
    header_remove('Content-Type');
    header('Content-Type: ' . $asset['mime_type']);
    header('Content-Length: ' . (string) filesize($file));
    header('Content-Disposition: inline; filename="asset"');
    header('X-Content-Type-Options: nosniff');
    readfile($file);
    exit;
}

if (preg_match('#^/projects/([0-9a-f-]{36})/media/([0-9a-f-]{36})$#i', $path, $matches) && $method === 'DELETE') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    $projectId = uuidBinary($matches[1]);
    $assetId = uuidBinary($matches[2]);
    requireProjectAccess($pdo, $session, $projectId, true);
    $statement = $pdo->prepare('SELECT storage_key_ciphertext, storage_key_nonce, storage_key_auth_tag FROM media_assets WHERE id = ? AND project_id = ? AND deleted_at IS NULL LIMIT 1');
    $statement->execute([$assetId, $projectId]);
    $asset = $statement->fetch();
    if (!$asset) respond(404, ['error' => 'not_found']);
    $pdo->prepare('UPDATE media_assets SET deleted_at = UTC_TIMESTAMP(6) WHERE id = ?')->execute([$assetId]);
    $storageKey = decryptValue($config, $asset['storage_key_ciphertext'], $asset['storage_key_nonce'], $asset['storage_key_auth_tag']);
    $file = mediaStorageRoot($config) . DIRECTORY_SEPARATOR . $storageKey;
    if (is_file($file)) @unlink($file);
    respond(204, []);
}

if ($method === 'POST' && $path === '/cms/landing') {
    $session = authenticated($pdo, $config);
    requireCsrf($session);
    requireCapability($pdo, $session, 'cms.landing.edit');
    $body = requestBody();
    $locale = localeValue(text($body, 'locale', 10));
    $html = text($body, 'html', 300000);
    $css = text($body, 'css', 300000);
    if ($html === '' || $css === '') {
        respond(422, ['error' => 'empty_content']);
    }
    $payload = json_encode(['html' => $html, 'css' => $css], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    [$ciphertext, $nonce, $tag] = encryptValue($config, $payload);
    $statement = $pdo->prepare('INSERT INTO cms_landing_pages (id, locale, content_ciphertext, content_nonce, content_auth_tag, updated_by_user_id) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE content_ciphertext = VALUES(content_ciphertext), content_nonce = VALUES(content_nonce), content_auth_tag = VALUES(content_auth_tag), revision_no = revision_no + 1, status = \'published\', updated_by_user_id = VALUES(updated_by_user_id)');
    $statement->execute([uuidV7(), $locale, $ciphertext, $nonce, $tag, $session['user_id']]);
    respond(200, ['status' => 'published', 'locale' => $locale]);
}

respond(404, ['error' => 'not_found']);
