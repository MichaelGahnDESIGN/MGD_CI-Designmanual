<?php

declare(strict_types=1);

/**
 * Gemeinsame, rein serverseitige Regeln für Tarife und Backoffice-Rechte.
 *
 * Diese Datei enthält keine Datenbankzugriffe und damit keine versteckten
 * Nebenwirkungen. Sie wird sowohl von API-Endpunkten als auch vom kleinen
 * Shared-Hosting-Test verwendet. Die API bleibt die einzige Instanz, welche
 * ein Entitlement tatsächlich wirksam macht.
 *
 * @return array<string, array<string, int|bool|string>>
 */
function ciDefaultPlanCatalog(): array {
    $mb = 1024 * 1024;
    return [
        'free' => [
            'slug' => 'free',
            'label' => 'Free',
            'monthly_price_cents' => 0,
            'yearly_price_cents' => 0,
            'project_slots' => 1,
            'storage_bytes' => 100 * $mb,
            'logo_variant_limit' => 1,
            'font_family_limit' => 0,
            'template_limit' => 1,
            'core_features_included' => true,
            'available' => true,
        ],
        'creator' => [
            'slug' => 'creator',
            'label' => 'Creator',
            'monthly_price_cents' => 900,
            'yearly_price_cents' => 9000,
            'project_slots' => 4,
            'storage_bytes' => 500 * $mb,
            'logo_variant_limit' => 3,
            'font_family_limit' => 1,
            'template_limit' => 3,
            'core_features_included' => true,
            'available' => false,
        ],
        'studio' => [
            'slug' => 'studio',
            'label' => 'Studio',
            'monthly_price_cents' => 1900,
            'yearly_price_cents' => 19000,
            'project_slots' => 12,
            'storage_bytes' => 1536 * $mb,
            'logo_variant_limit' => 8,
            'font_family_limit' => 3,
            'template_limit' => 8,
            'core_features_included' => true,
            'available' => false,
        ],
        'ultimate' => [
            'slug' => 'ultimate',
            'label' => 'Ultimate',
            'monthly_price_cents' => 4900,
            'yearly_price_cents' => 49000,
            'project_slots' => 25,
            'storage_bytes' => 3072 * $mb,
            'logo_variant_limit' => 20,
            'font_family_limit' => 10,
            'template_limit' => 20,
            'core_features_included' => true,
            // 3 GB wird erst nach belastbarer EU-Speicher-/Kostenkontrolle aktiv.
            'available' => false,
        ],
    ];
}

/** @param array<string, int|bool|string> $plan */
function ciAnnualSavingsPercent(array $plan): int {
    $monthly = (int) $plan['monthly_price_cents'];
    $yearly = (int) $plan['yearly_price_cents'];
    if ($monthly <= 0 || $yearly >= $monthly * 12) {
        return 0;
    }
    return (int) round((($monthly * 12 - $yearly) / ($monthly * 12)) * 100);
}

/**
 * Least Privilege: Moderation darf nur dokumentierte Fälle bearbeiten.
 * Zahlungs-, Identitäts- und Rechteverwaltung sind ausschließlich Admins
 * vorbehalten. Die Datenbank erzwingt diese Zuordnung zusätzlich.
 */
function ciRoleCanReceiveCapability(string $role, string $capability): bool {
    $allowed = [
        'member' => [],
        'moderator' => [
            'backoffice.access',
            'moderation.case.read',
            'moderation.case.manage',
        ],
        'admin' => [
            'admin.access',
            'backoffice.access',
            'users.manage',
            'users.status.manage',
            'roles.manage',
            'entitlements.manage',
            'billing.read',
            'billing.catalog.manage',
            'moderation.case.read',
            'moderation.case.manage',
            'security.audit.read',
            'cms.landing.view',
            'cms.landing.edit',
        ],
    ];
    return in_array($capability, $allowed[$role] ?? [], true);
}
