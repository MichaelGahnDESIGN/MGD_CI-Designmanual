<?php

declare(strict_types=1);

require dirname(__DIR__) . '/lib/BackofficePolicy.php';

/** Kleine, frameworkfreie Regressionstests für shared Hosting. */
function expectTrue(bool $condition, string $message): void {
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$plans = ciDefaultPlanCatalog();
expectTrue(array_keys($plans) === ['free', 'creator', 'studio', 'ultimate'], 'Tarifreihenfolge muss stabil sein.');
expectTrue($plans['free']['core_features_included'] === true, 'Free enthält alle Grundfunktionen.');
foreach (array_slice($plans, 1) as $plan) {
    expectTrue($plan['yearly_price_cents'] < $plan['monthly_price_cents'] * 12, 'Jährlicher Preis muss wirklich günstiger sein.');
    expectTrue(ciAnnualSavingsPercent($plan) > 0, 'Jahresrabatt muss positiv sein.');
}

expectTrue(ciRoleCanReceiveCapability('moderator', 'moderation.case.manage'), 'Moderator darf Fälle bearbeiten.');
expectTrue(!ciRoleCanReceiveCapability('moderator', 'billing.catalog.manage'), 'Moderator darf keine Tarife ändern.');
expectTrue(!ciRoleCanReceiveCapability('moderator', 'users.status.manage'), 'Moderator darf keine Konten sperren.');

echo "Backoffice policy tests passed.\n";
