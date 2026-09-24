import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mgd_ci_builder/main.dart';
import 'package:mgd_ci_builder/features/legal/legal_document.dart';
import 'package:mgd_ci_builder/features/onboarding/brand_asset_picker.dart';
import 'package:mgd_ci_builder/features/billing/plan_catalog.dart';
import 'package:mgd_ci_builder/features/account/account_repository.dart';

void main() {
  test('Tarifkatalog zeigt alle Tarife und einen echten Jahresvorteil', () {
    expect(PlanCatalog.publicPlans.map((plan) => plan.slug), [
      'free',
      'creator',
      'studio',
      'ultimate',
    ]);
    for (final plan in PlanCatalog.publicPlans.where((plan) => plan.isPaid)) {
      expect(plan.yearlyPriceCents, lessThan(plan.monthlyPriceCents * 12));
      expect(plan.annualSavingsPercent, greaterThan(0));
    }
    expect(PlanCatalog.publicPlans.first.includesAllCoreFeatures, isTrue);
  });

  test('resolves public legal documents from direct and hash URLs', () {
    expect(
      LegalDocumentContent.fromUri(Uri.parse('https://ci.example/impressum')),
      LegalDocument.imprint,
    );
    expect(
      LegalDocumentContent.fromUri(
        Uri.parse('https://ci.example/#/datenschutz'),
      ),
      LegalDocument.privacy,
    );
  });

  testWidgets('shows the CI BUILDER landing page', (tester) async {
    await tester.pumpWidget(const CiBuilderApp());

    expect(
      find.text('Dein Markenmanual.\nKlar. Konsistent.\nBereit für überall.'),
      findsOneWidget,
    );
    expect(find.text('Projekt starten'), findsOneWidget);
    expect(find.text('DE'), findsOneWidget);
    expect(find.text('Impressum'), findsOneWidget);
    expect(find.text('AI-Philosophie'), findsOneWidget);
    expect(find.text('Michael Gahn DESIGN'), findsOneWidget);
    expect(find.text('Zahlung'), findsNothing);
    expect(find.text('Widerruf'), findsNothing);
    expect(find.text('Entwurf'), findsNothing);
  });

  testWidgets('offers a password reset entry from the login form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginPage(darkMode: false)),
    );

    expect(find.text('Passwort vergessen?'), findsOneWidget);
    await tester.tap(find.text('Passwort vergessen?'));
    await tester.pumpAndSettle();

    expect(find.text('Kennwort zurücksetzen.'), findsOneWidget);
  });

  testWidgets('opens the account and security area from mobile navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: BuilderHome(csrfToken: 'test')),
    );
    await tester.pump();
    await tester.tap(find.text('Konto'));
    await tester.pumpAndSettle();

    expect(find.text('Konto & Sicherheit'), findsOneWidget);
    expect(find.text('Kennwort ändern'), findsOneWidget);
  });

  testWidgets('theme button reflects the active brightness after toggling', (
    tester,
  ) async {
    await tester.pumpWidget(const CiBuilderApp());

    await tester.tap(find.byKey(const Key('landing.themeToggle')));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(LandingPage))).brightness,
      Brightness.dark,
    );
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('uses a shader-independent press response for the web app', (
    tester,
  ) async {
    await tester.pumpWidget(const CiBuilderApp());

    final theme = Theme.of(tester.element(find.byType(LandingPage)));
    expect(theme.splashFactory, InkRipple.splashFactory);
  });

  testWidgets('shows a dedicated theme control in the signed-in header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: BuilderHome(csrfToken: 'test')),
    );

    expect(find.byKey(const Key('builder.themeToggle')), findsOneWidget);
  });

  testWidgets('shows the admin backend shortcut only with server capability', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          profileLoader: () async => _profile(
            roles: const ['admin'],
            capabilities: const ['backoffice.access', 'billing.read'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('builder.backofficeShortcut')), findsOneWidget);
    expect(find.text('Zum Admin-Backend'), findsOneWidget);
  });

  testWidgets('labels a moderator shortcut without exposing billing access', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          profileLoader: () async => _profile(
            roles: const ['moderator'],
            capabilities: const [
              'backoffice.access',
              'moderation.case.read',
              'moderation.case.manage',
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('builder.backofficeShortcut')), findsOneWidget);
    expect(find.text('Zum Moderations-Backend'), findsOneWidget);
    expect(find.text('Zum Admin-Backend'), findsNothing);
  });

  testWidgets('hides the backend shortcut without backoffice capability', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          profileLoader: () async => _profile(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('builder.backofficeShortcut')), findsNothing);
  });

  testWidgets('keeps the landing hierarchy compact on tablet viewports', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(730, 889);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CiBuilderApp());

    final headline = find.text(
      'Dein Markenmanual.\nKlar. Konsistent.\nBereit für überall.',
    );
    final headlineWidget = tester.widget<Text>(headline);
    final headlineTheme = Theme.of(tester.element(headline))
        .textTheme
        .headlineLarge;

    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('CI BUILDER')).dy, lessThan(80));
    expect(tester.getTopLeft(headline).dy, lessThan(240));
    expect(headlineWidget.style?.fontSize, 56);
    expect(headlineTheme?.fontFamily, 'Open Sans');
  });

  testWidgets('renders the compact mobile header without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CiBuilderApp());

    expect(tester.takeException(), isNull);
    expect(find.text('CI BUILDER'), findsOneWidget);
    expect(find.text('Projekt starten'), findsOneWidget);
  });

  testWidgets('keeps signed-in navigation usable in phone landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(812, 375);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: BuilderHome(csrfToken: 'test')),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Konto'));
    await tester.pumpAndSettle();
    expect(find.text('Konto & Sicherheit'), findsOneWidget);
  });

  testWidgets('opens the public imprint from the landing footer', (
    tester,
  ) async {
    await tester.pumpWidget(const CiBuilderApp());

    await tester.tap(find.text('Nur notwendige verwenden'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Impressum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Impressum'));
    await tester.pumpAndSettle();

    expect(find.text('Angaben gemäß § 5 DDG'), findsOneWidget);
    expect(find.textContaining('Dr.-Theodor-Brugsch-Str. 12'), findsOneWidget);
  });

  testWidgets('shows privacy choices without optional preselection', (
    tester,
  ) async {
    await tester.pumpWidget(const CiBuilderApp());

    expect(find.text('Privatsphäre-Einstellungen'), findsOneWidget);
    await tester.tap(find.text('Einstellungen'));
    await tester.pumpAndSettle();

    expect(find.text('Technisch notwendig'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Nicht eingesetzt'), findsNWidgets(3));
  });

  testWidgets('opens the logo picker from the complete material card', (
    tester,
  ) async {
    final picker = _FakeBrandAssetPicker(
      BrandAssetSelection(
        name: 'marke.svg',
        sizeBytes: 4200,
        mimeType: 'image/svg+xml',
        bytes: Uint8List(0),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          assetPicker: picker,
          projectCreator: _testProjectCreator,
        ),
      ),
    );
    await _openMaterialStep(tester);

    await tester.tap(find.byKey(const Key('onboarding.logoUpload')));
    await tester.pumpAndSettle();

    expect(picker.requestedKinds, [BrandAssetKind.logo]);
    expect(find.text('marke.svg'), findsWidgets);
    expect(find.text('Ausgewählt'), findsOneWidget);
  });

  testWidgets('material step can be skipped explicitly and reopened later', (
    tester,
  ) async {
    final picker = _FakeBrandAssetPicker(null);

    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          assetPicker: picker,
          projectCreator: _testProjectCreator,
        ),
      ),
    );
    await _openMaterialStep(tester);

    expect(find.text('Jetzt überspringen'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding.skipMaterial')));
    await tester.pumpAndSettle();
    expect(find.text('Deine editierbare Ausgangsbasis.'), findsOneWidget);

    await tester.tap(find.text('Projektbasis erstellen'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project.material.manage')), findsOneWidget);

    await tester.tap(find.byKey(const Key('project.material.manage')));
    await tester.pumpAndSettle();
    expect(find.text('Gib deiner Marke Material.'), findsOneWidget);
    expect(find.byKey(const Key('onboarding.logoUpload')), findsOneWidget);
  });

  testWidgets('material flow stays usable on a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: BuilderHome(
          csrfToken: 'test',
          assetPicker: _FakeBrandAssetPicker(null),
          projectCreator: _testProjectCreator,
        ),
      ),
    );
    await _openMaterialStep(tester);

    expect(find.byKey(const Key('onboarding.logoUpload')), findsOneWidget);
    expect(find.byKey(const Key('onboarding.skipMaterial')), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding.skipMaterial')));
    await tester.pumpAndSettle();

    expect(find.text('Deine editierbare Ausgangsbasis.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the material step legible in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.dark,
          ),
        ),
        home: BuilderHome(
          csrfToken: 'test',
          assetPicker: _FakeBrandAssetPicker(null),
          projectCreator: _testProjectCreator,
        ),
      ),
    );
    await _openMaterialStep(tester);

    final uploadCards = find.descendant(
      of: find.byKey(const Key('onboarding.logoUpload')),
      matching: find.byType(Material),
    );
    expect(tester.widget<Material>(uploadCards).color, isNot(Colors.white));
  });

  testWidgets(
    'offers HTTPS image URLs as a storage-free material alternative',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BuilderHome(
            csrfToken: 'test',
            assetPicker: _FakeBrandAssetPicker(null),
            projectCreator: _testProjectCreator,
          ),
        ),
      );
      await _openMaterialStep(tester);

      expect(find.byKey(const Key('onboarding.logoUrl')), findsOneWidget);
      expect(find.textContaining('HTTPS-URL'), findsWidgets);
    },
  );
}

Future<void> _openMaterialStep(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Projekt anlegen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Projekt anlegen'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, 'Testprojekt');
  await tester.tap(find.text('Weiter'));
  await tester.pumpAndSettle();
}

Future<void> _testProjectCreator({
  required String name,
  required String company,
  required String description,
  required String fontFamily,
}) async {}

AccountProfile _profile({
  List<String> roles = const [],
  List<String> capabilities = const [],
}) => AccountProfile(
  username: 'test',
  email: 'test@example.invalid',
  planLabel: 'Free',
  projectsUsed: 0,
  projectsTotal: 1,
  storageUsedBytes: 0,
  storageTotalBytes: 100 * 1024 * 1024,
  roles: roles,
  capabilities: capabilities,
);

class _FakeBrandAssetPicker implements BrandAssetPicker {
  _FakeBrandAssetPicker(this.result);

  final BrandAssetSelection? result;
  final List<BrandAssetKind> requestedKinds = [];

  @override
  Future<BrandAssetSelection?> pick(BrandAssetKind kind) async {
    requestedKinds.add(kind);
    return result;
  }
}
