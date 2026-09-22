<?php

declare(strict_types=1);

// Copy this file to config.php only on the server. config.php is ignored by
// Git and must sit outside the deployed public document root where possible.
// Generate independent 32-byte base64 keys with a cryptographically secure
// source; never reuse the database password as an application key.
return [
    'environment' => 'production',
    'database' => [
        'host' => '127.0.0.1',
        'port' => 3306,
        'name' => 'replace_me',
        'user' => 'replace_me',
        'password' => 'replace_me',
    ],
    'crypto' => [
        'data_key_b64' => 'replace_with_32_byte_base64_key',
        'lookup_key_b64' => 'replace_with_32_byte_base64_key',
    ],
    'session' => [
        'cookie_name' => 'ci_builder_session',
        'ttl_seconds' => 28800,
    ],
    // Absoluter Pfad außerhalb von public_html. Der Fallback des Backends
    // lautet <Backend-Ordner>/private-media und ist ebenfalls nicht öffentlich.
    'storage' => [
        'media_root' => '/absolute/path/outside-public-webroot/ci-builder-media',
    ],
];
