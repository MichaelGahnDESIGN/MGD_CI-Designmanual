import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'features/account/account_page.dart';
import 'features/auth/password_reset_pages.dart';
import 'features/editor/typography/typography_selector.dart';
import 'features/landing/landing_layout.dart';
import 'features/legal/cookie_consent.dart';
import 'features/legal/landing_footer.dart';
import 'features/legal/legal_document.dart';
import 'features/legal/legal_page.dart';
import 'features/onboarding/brand_asset_picker.dart';
import 'features/projects/project_repository.dart';
import 'features/settings/theme_preference.dart';
import 'shared/ci_brand_mark.dart';

void main() => runApp(const CiBuilderApp());

enum AppLanguage { de, en }

class LandingCopy {
  const LandingCopy({
    required this.eyebrow,
    required this.headline,
    required this.description,
    required this.start,
    required this.login,
    required this.open,
    required this.slot,
    required this.export,
    required this.hosting,
  });

  final String eyebrow;
  final String headline;
  final String description;
  final String start;
  final String login;
  final String open;
  final String slot;
  final String export;
  final String hosting;

  static const de = LandingCopy(
    eyebrow: 'MARKENHANDHABUNG\nMIT HALTUNG.',
    headline: 'Dein Markenmanual.\nKlar. Konsistent.\nBereit für überall.',
    description: 'Der Michael Gahn DESIGN CI BUILDER verwandelt Markenwissen in ein editierbares Designmanual und einen Social-Media-Codex – für Agenturen, Teams und Kunden.',
    start: 'Projekt starten',
    login: 'Anmelden',
    open: 'CI BUILDER öffnen',
    slot: '1 kostenloser Projektslot',
    export: 'HTML- & PDF-Export',
    hosting: 'Privates Hosting in Deutschland',
  );

  static const en = LandingCopy(
    eyebrow: 'BRAND SYSTEMS\nWITH INTENT.',
    headline: 'Your brand manual.\nClear. Consistent.\nReady for everywhere.',
    description: 'Michael Gahn DESIGN CI BUILDER turns brand knowledge into an editable design manual and social media codex – for agencies, teams and clients.',
    start: 'Start a project',
    login: 'Sign in',
    open: 'Open CI BUILDER',
    slot: '1 free project slot',
    export: 'HTML & PDF export',
    hosting: 'Private hosting in Germany',
  );
}

class CiBuilderApp extends StatefulWidget {
  const CiBuilderApp({super.key});

  @override
  State<CiBuilderApp> createState() => _CiBuilderAppState();
}

class _CiBuilderAppState extends State<CiBuilderApp> {
  ThemeMode _themeMode = loadDarkModePreference()
      ? ThemeMode.dark
      : ThemeMode.light;
  AppLanguage _language = AppLanguage.de;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CI BUILDER',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      initialRoute: LegalDocumentContent.fromUri(Uri.base)?.route ?? '/',
      onGenerateRoute: _route,
    );
  }

  Route<void> _route(RouteSettings settings) {
    final resetToken = Uri.base.queryParameters['reset'];
    if (resetToken != null && resetToken.isNotEmpty) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => PasswordResetConfirmPage(token: resetToken),
      );
    }
    final document = LegalDocumentContent.fromRoute(settings.name);
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => document == null
          ? LandingPage(
              language: _language,
              onLanguageChanged: (value) => setState(() => _language = value),
              onThemeToggle: _toggleTheme,
            )
          : LegalPage(
              document: document,
              darkMode: _themeMode == ThemeMode.dark,
              onThemeToggle: _toggleTheme,
            ),
    );
  }

  void _toggleTheme() {
    final darkMode = _themeMode != ThemeMode.dark;
    saveDarkModePreference(darkMode);
    setState(() => _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF5F3EE) : const Color(0xFF111114);
    final canvas = dark ? const Color(0xFF111114) : const Color(0xFFF6F5F2);
    final surface = dark ? const Color(0xFF1B1B20) : const Color(0xFFFFFEFC);
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB7F34A),
        brightness: brightness,
        primary: ink,
        onPrimary: dark ? const Color(0xFF111114) : Colors.white,
        surface: surface,
        onSurface: ink,
      ),
      useMaterial3: true,
      fontFamily: 'Open Sans',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontFamily: 'Open Sans',
          fontSize: 58,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.8,
          height: .95,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontFamily: 'Open Sans',
          fontSize: 31,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(
          color: dark ? const Color(0xFFD5D1D0) : const Color(0xFF52515A),
          height: 1.5,
        ),
        bodyMedium: TextStyle(color: ink),
        bodySmall: TextStyle(color: ink),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF24242A) : const Color(0xFFFFFEFC),
        labelStyle: TextStyle(color: ink),
        floatingLabelStyle: TextStyle(color: ink),
        hintStyle: TextStyle(
          color: dark ? const Color(0xFFAAA7B0) : const Color(0xFF6D6A72),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: dark ? const Color(0xFF77737D) : const Color(0xFF77736F),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ink, width: 2),
        ),
      ),
    );
  }
}

/// Authentifizierungsflächen verwenden ausschließlich semantische Themefarben.
/// So bleibt Text in Light und Dark Mode kontrastreich und lesbar.
BoxDecoration _authCardDecoration(bool dark) {
  return BoxDecoration(
    color: dark ? const Color(0xFF1B1B20) : const Color(0xFFFFFEFC),
    border: Border.all(
      color: dark ? const Color(0xFF4E4B54) : const Color(0xFFDDDBD8),
    ),
    borderRadius: BorderRadius.circular(20),
  );
}

/// Auth-Felder werden bewusst nicht aus einem Routen-Kontext abgeleitet.
/// Damit bleibt der manuell gewählte Modus auch nach Navigation konsistent.
InputDecoration _authInputDecoration({required bool dark, String? hintText}) =>
    InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: dark ? const Color(0xFF24242A) : const Color(0xFFFFFEFC),
      hintStyle: TextStyle(
        color: dark ? const Color(0xFFAAA7B0) : const Color(0xFF6D6A72),
      ),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: dark ? const Color(0xFF77737D) : const Color(0xFF77736F),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: dark ? const Color(0xFFF5F3EE) : const Color(0xFF111114),
          width: 2,
        ),
      ),
    );

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required this.onThemeToggle,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final copy = language == AppLanguage.de ? LandingCopy.de : LandingCopy.en;
    // Die Theme-Farbe stammt immer aus dem aktiven Inherited Theme. Damit
    // aktualisiert sich Icon und Tooltip auch innerhalb einer bestehenden Route.
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) {
                final layout = LandingLayout.forWidth(viewport.maxWidth);
                return SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: layout.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CiBrandMark(),
                                const Spacer(),
                                if (layout.compactHeader)
                                  PopupMenuButton<AppLanguage>(
                                    tooltip: 'Sprache',
                                    initialValue: language,
                                    onSelected: onLanguageChanged,
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: AppLanguage.de,
                                        child: Text('Deutsch'),
                                      ),
                                      PopupMenuItem(
                                        value: AppLanguage.en,
                                        child: Text('English'),
                                      ),
                                    ],
                                    child: Text(
                                      language == AppLanguage.de ? 'DE' : 'EN',
                                    ),
                                  )
                                else ...[
                                  TextButton(
                                    onPressed: () =>
                                        onLanguageChanged(AppLanguage.de),
                                    child: Text(
                                      'DE',
                                      style: TextStyle(
                                        fontWeight: language == AppLanguage.de
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        onLanguageChanged(AppLanguage.en),
                                    child: Text(
                                      'EN',
                                      style: TextStyle(
                                        fontWeight: language == AppLanguage.en
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                IconButton(
                                  key: const Key('landing.themeToggle'),
                                  onPressed: onThemeToggle,
                                  tooltip: darkMode ? 'Lightmode' : 'Darkmode',
                                  icon: Icon(
                                    darkMode
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (layout.iconOnlyLogin)
                                  IconButton(
                                    onPressed: () => _openLogin(context),
                                    tooltip: copy.login,
                                    icon: const Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: () => _openLogin(context),
                                    child: Text(copy.login),
                                  ),
                                if (!layout.compactHeader) ...[
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: () => _openLogin(context),
                                    child: Text(copy.open),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: layout.heroSpacing),
                            Text(
                              copy.eyebrow,
                              style: TextStyle(
                                fontSize: layout.eyebrowSize,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              copy.headline,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontSize: layout.headlineSize,
                                    letterSpacing: layout.headlineLetterSpacing,
                                    height: layout.headlineHeight,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: Text(
                                copy.description,
                                style: TextStyle(
                                  fontSize: layout.bodySize,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            FilledButton.icon(
                              onPressed: () => _openLogin(context),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(copy.start),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                              ),
                            ),
                            SizedBox(height: layout.benefitSpacing),
                            Wrap(
                              spacing: 26,
                              runSpacing: 16,
                              children: [
                                _LandingBenefit(label: copy.slot),
                                _LandingBenefit(label: copy.export),
                                _LandingBenefit(label: copy.hosting),
                              ],
                            ),
                            SizedBox(height: layout.benefitSpacing),
                            _LandingExplainer(language: language),
                            const SizedBox(height: 86),
                            LandingFooter(
                              onOpenDocument: (document) =>
                                  Navigator.pushNamed(context, document.route),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const CookieConsentBanner(),
        ],
      ),
    );
  }

  void _openLogin(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      // Die Route selbst bleibt beim Themewechsel bestehen. Deshalb wird
      // der Modus erst beim Klick aus dem aktuell sichtbaren Theme gelesen.
      builder: (_) => LoginPage(
        darkMode:
            Theme.of(context).scaffoldBackgroundColor.computeLuminance() < .1,
      ),
    ),
  );
}

class _LandingBenefit extends StatelessWidget {
  const _LandingBenefit({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

/// Erklärt den Nutzen der Plattform direkt auf der Startseite, ohne den
/// Einstieg in den Assistenten mit technischen Details zu überladen.
class _LandingExplainer extends StatelessWidget {
  const _LandingExplainer({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final german = language == AppLanguage.de;
    final dark =
        Theme.of(context).scaffoldBackgroundColor.computeLuminance() < .1;
    final cards = german
        ? const [
            _ExplainerCardData(
              icon: Icons.account_balance_outlined,
              title: 'Markenbasis',
              text: 'Lege Unternehmen, Positionierung, Logo und Bildmaterial als gemeinsame Grundlage an.',
            ),
            _ExplainerCardData(
              icon: Icons.palette_outlined,
              title: 'Designsystem',
              text: 'Halte Farben, Typografie, Logo-Regeln und Gestaltungsprinzipien nachvollziehbar fest.',
            ),
            _ExplainerCardData(
              icon: Icons.campaign_outlined,
              title: 'Social-Media-Codex',
              text: 'Definiere Tonalität, Bildsprache und wiederverwendbare Leitlinien für deinen Auftritt.',
            ),
          ]
        : const [
            _ExplainerCardData(
              icon: Icons.account_balance_outlined,
              title: 'Brand foundation',
              text: 'Start with your company, positioning, logo and imagery as one shared foundation.',
            ),
            _ExplainerCardData(
              icon: Icons.palette_outlined,
              title: 'Design system',
              text: 'Document colours, typography, logo rules and design principles in one clear place.',
            ),
            _ExplainerCardData(
              icon: Icons.campaign_outlined,
              title: 'Social media codex',
              text: 'Define tone of voice, imagery and reusable guidelines for every channel.',
            ),
          ];

    return Semantics(
      container: true,
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            german
                ? 'Was du mit dem CI BUILDER machst.'
                : 'What CI BUILDER helps you create.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Text(
              german
                  ? 'Du führst deine Marke Schritt für Schritt zu einem verständlichen Manual – für dein Team, deine Kunden und alle, die deine Marke anwenden.'
                  : 'Guide your brand step by step into a clear manual for your team, clients and everyone who uses it.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map((card) => _ExplainerCard(data: card, dark: dark))
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          Text(
            german
                ? 'Am Ende exportierst du dein Designmanual als HTML-Projekt oder PDF und kannst es direkt mit anderen teilen.'
                : 'At the end, export your design manual as an HTML project or PDF and share it directly with others.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ExplainerCardData {
  const _ExplainerCardData({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({required this.data, required this.dark});

  final _ExplainerCardData data;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    width: 300,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF1B1B20) : const Color(0xFFFFFEFC),
      border: Border.all(
        color: dark ? const Color(0xFF4E4B54) : const Color(0xFFDDDBD8),
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, size: 26),
        const SizedBox(height: 20),
        Text(data.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(data.text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.darkMode});

  final bool darkMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identity = TextEditingController();
  final _password = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _identity.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(30),
            decoration: _authCardDecoration(widget.darkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CiBrandMark(),
                const SizedBox(height: 42),
                Text(
                  'Willkommen zurück.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Melde dich mit deinem Benutzernamen oder deiner E-Mail-Adresse an.',
                ),
                const SizedBox(height: 26),
                const _FormLabel('Benutzername oder E-Mail'),
                TextField(
                  controller: _identity,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _authInputDecoration(dark: widget.darkMode),
                ),
                const SizedBox(height: 16),
                const _FormLabel('Kennwort'),
                TextField(
                  controller: _password,
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                  decoration: _authInputDecoration(dark: widget.darkMode),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFF8D0000)),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _login,
                    child: Text(
                      _sending ? 'Anmeldung wird geprüft …' : 'Sicher anmelden',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  key: const Key('auth.forgotPassword'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PasswordResetRequestPage(),
                    ),
                  ),
                  child: const Text('Passwort vergessen?'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zurück zur Startseite'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          RegistrationPage(darkMode: widget.darkMode),
                    ),
                  ),
                  child: const Text('Kostenloses Konto erstellen'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _login() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.base.resolve('api/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': _identity.text,
          'password': _password.text,
        }),
      );
      final body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(
          () => _error = 'Anmeldung nicht möglich. Bitte prüfe deine Angaben.',
        );
        return;
      }
      final csrf = body['csrf_token'] as String;
      final mustChange =
          (body['user'] as Map<String, dynamic>)['must_change_password']
              as bool? ??
          false;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => mustChange
              ? PasswordChangePage(csrfToken: csrf, darkMode: widget.darkMode)
              : BuilderHome(csrfToken: csrf),
        ),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Der Dienst ist gerade nicht erreichbar.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required this.darkMode});

  final bool darkMode;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(30),
            decoration: _authCardDecoration(widget.darkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CiBrandMark(),
                const SizedBox(height: 36),
                Text(
                  'Konto erstellen.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Ein kostenloser Projektslot ist inklusive.'),
                const SizedBox(height: 22),
                const _FormLabel('Benutzername'),
                TextField(
                  controller: _username,
                  autocorrect: false,
                  decoration: _authInputDecoration(dark: widget.darkMode),
                ),
                const SizedBox(height: 14),
                const _FormLabel('E-Mail-Adresse'),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: _authInputDecoration(dark: widget.darkMode),
                ),
                const SizedBox(height: 14),
                const _FormLabel('Kennwort'),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: _authInputDecoration(
                    dark: widget.darkMode,
                    hintText:
                        'Mindestens 14 Zeichen, Groß-/Kleinbuchstabe, Zahl',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFF8D0000)),
                    ),
                  ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _register,
                    child: Text(
                      _sending
                          ? 'Konto wird erstellt …'
                          : 'Konto sicher erstellen',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zurück zur Anmeldung'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _register() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.base.resolve('api/auth/register'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username.text,
          'email': _email.text,
          'password': _password.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konto erstellt. Du kannst dich jetzt anmelden.'),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(
          () => _error = response.statusCode == 429
              ? 'Zu viele Versuche. Bitte warte kurz.'
              : 'Konto konnte nicht erstellt werden. Prüfe deine Angaben.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Der Dienst ist gerade nicht erreichbar.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({
    super.key,
    required this.csrfToken,
    required this.darkMode,
  });
  final String csrfToken;
  final bool darkMode;

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Container(
          width: 440,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(30),
          decoration: _authCardDecoration(widget.darkMode),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neues Kennwort festlegen.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              const Text(
                'Aus Sicherheitsgründen musst du dein temporäres Kennwort jetzt ersetzen.',
              ),
              const SizedBox(height: 24),
              const _FormLabel('Temporäres Kennwort'),
              TextField(
                controller: _current,
                obscureText: true,
                decoration: _authInputDecoration(dark: widget.darkMode),
              ),
              const SizedBox(height: 16),
              const _FormLabel('Neues Kennwort'),
              TextField(
                controller: _next,
                obscureText: true,
                decoration: _authInputDecoration(
                  dark: widget.darkMode,
                  hintText: 'Mindestens 14 Zeichen, Groß-/Kleinbuchstabe, Zahl',
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFF8D0000)),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sending ? null : _change,
                  child: Text(
                    _sending
                        ? 'Wird gespeichert …'
                        : 'Kennwort sicher speichern',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _change() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.base.resolve('api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': widget.csrfToken,
        },
        body: jsonEncode({
          'current_password': _current.text,
          'new_password': _next.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => BuilderHome(csrfToken: widget.csrfToken),
          ),
          (_) => false,
        );
        return;
      }
      setState(() => _error = 'Kennwort konnte nicht gespeichert werden.');
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Der Dienst ist gerade nicht erreichbar.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class BuilderHome extends StatefulWidget {
  const BuilderHome({
    super.key,
    required this.csrfToken,
    this.assetPicker,
    this.projectCreator,
  });

  final String csrfToken;
  final BrandAssetPicker? assetPicker;
  final Future<void> Function({
    required String name,
    required String company,
    required String description,
    required String fontFamily,
  })?
  projectCreator;

  @override
  State<BuilderHome> createState() => _BuilderHomeState();
}

class _BuilderHomeState extends State<BuilderHome> {
  int _selectedSection = 0;
  late final BrandAssetPicker _assetPicker;
  late final ProjectRepository _projects;
  List<ProjectSummary> _projectList = const [];
  bool _loadingProjects = true;
  BrandAssetSelection? _logo;
  BrandAssetSelection? _referenceImage;

  @override
  void initState() {
    super.initState();
    _assetPicker = widget.assetPicker ?? createBrandAssetPicker();
    _projects = ProjectRepository(widget.csrfToken);
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1040;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide) const _Sidebar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(wide ? 32 : 20),
                child: Column(
                  children: [
                    _TopBar(onMenu: () {}),
                    const SizedBox(height: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _selectedSection == 0
                            ? _Dashboard(
                                projects: _projectList,
                                loading: _loadingProjects,
                                onCreate: _openAssistant,
                                onOpenMedia: _openMedia,
                              )
                            : _selectedSection == 1
                            ? _AssistantWorkspace(
                                logo: _logo,
                                referenceImage: _referenceImage,
                                onAddMaterial: () =>
                                    _openAssistant(initialStep: 1),
                              )
                            : AccountPage(
                                csrfToken: widget.csrfToken,
                                onChangePassword: () =>
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => PasswordChangePage(
                                          csrfToken: widget.csrfToken,
                                          darkMode:
                                              Theme.of(context).brightness ==
                                              Brightness.dark,
                                        ),
                                      ),
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedSection,
              onDestinationSelected: (value) =>
                  setState(() => _selectedSection = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Übersicht',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_rounded),
                  label: 'Assistent',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Konto',
                ),
              ],
            ),
    );
  }

  void _openAssistant({int initialStep = 0}) {
    setState(() => _selectedSection = 1);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewProjectSheet(
        assetPicker: _assetPicker,
        initialStep: initialStep,
        initialLogo: _logo,
        initialReferenceImage: _referenceImage,
        onCreateProject: _createProject,
        onMaterialChanged: (kind, selection) {
          setState(() {
            if (kind == BrandAssetKind.logo) {
              _logo = selection;
            } else {
              _referenceImage = selection;
            }
          });
        },
      ),
    );
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _projects.list();
      if (mounted) setState(() => _projectList = projects);
    } catch (_) {
      // Die leere Ansicht bleibt nutzbar; Details werden nicht an den Client geleakt.
    } finally {
      if (mounted) setState(() => _loadingProjects = false);
    }
  }

  Future<void> _createProject({
    required String name,
    required String company,
    required String description,
    required String fontFamily,
  }) async {
    if (widget.projectCreator != null) {
      await widget.projectCreator!(
        name: name,
        company: company,
        description: description,
        fontFamily: fontFamily,
      );
      return;
    }
    final project = await _projects.create(
      name: name,
      company: company,
      description: description,
      fontFamily: fontFamily,
    );
    // Erst nach der Projektanlage existiert die serverseitige Berechtigung.
    // Upload-Fehler werden an den Assistenten zurückgegeben; die Datei bleibt
    // bis dahin ausschließlich im flüchtigen Browser-Arbeitsspeicher.
    if (_logo != null) {
      await _projects.uploadAsset(
        projectId: project.id,
        kind: BrandAssetKind.logo,
        selection: _logo!,
      );
    }
    if (_referenceImage != null) {
      await _projects.uploadAsset(
        projectId: project.id,
        kind: BrandAssetKind.referenceImage,
        selection: _referenceImage!,
      );
    }
    if (mounted) setState(() => _projectList = [project, ..._projectList]);
  }

  void _openMedia(ProjectSummary project) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectMediaSheet(
        project: project,
        repository: _projects,
        assetPicker: _assetPicker,
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      decoration: const BoxDecoration(
        color: Color(0xFF111114),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const SizedBox(height: 52),
          const _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Übersicht',
            active: true,
          ),
          const _NavItem(icon: Icons.folder_open_outlined, label: 'Projekte'),
          const _NavItem(icon: Icons.auto_awesome_outlined, label: 'Assistent'),
          const _NavItem(icon: Icons.layers_outlined, label: 'Vorlagen'),
          const _NavItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Erweiterungen',
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF24242A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREE PLAN',
                  style: TextStyle(
                    color: Color(0xFFBFBCCB),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1 von 1 Projektslot',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 1,
                  minHeight: 5,
                  color: Colors.white,
                  backgroundColor: Color(0xFF42414B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _NavItem(
            icon: Icons.help_outline_rounded,
            label: 'Hilfe & Feedback',
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Color(0xFF111114),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CI BUILDER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          Text(
            'MICHAEL GAHN DESIGN',
            style: TextStyle(
              color: Color(0xFFAAA8B3),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .75,
            ),
          ),
        ],
      ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF2D2C33) : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: active ? Colors.white : const Color(0xFFB5B3BE),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFCBC9D2),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu});
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          'Guten Morgen, Michael.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      IconButton(
        onPressed: onMenu,
        icon: const Icon(Icons.notifications_none_rounded),
      ),
      const SizedBox(width: 8),
      const CircleAvatar(
        backgroundColor: Color(0xFF111114),
        child: Text(
          'MG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.onCreate,
    required this.onOpenMedia,
    required this.projects,
    required this.loading,
  });
  final VoidCallback onCreate;
  final ValueChanged<ProjectSummary> onOpenMedia;
  final List<ProjectSummary> projects;
  final bool loading;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Text(
          'Baue Marken, die überall eindeutig wirken.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      const SizedBox(height: 18),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: const Text(
          'Der CI BUILDER führt dich vom ersten Logo bis zum fertigen Markenhandbuch – klar, konsistent und bereit für Web, Social Media und Print.',
        ),
      ),
      const SizedBox(height: 30),
      _ProjectSlotCard(onCreate: onCreate),
      if (loading)
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: CircularProgressIndicator(),
        )
      else if (projects.isNotEmpty) ...[
        const SizedBox(height: 28),
        Text('Deine Projekte', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...projects.map(
          (project) => Card(
            child: ListTile(
              title: Text(project.name),
              subtitle: Text(
                project.company?.isEmpty ?? true
                    ? project.fontFamily
                    : '${project.company} · ${project.fontFamily}',
              ),
              leading: const Icon(Icons.folder_open_outlined),
              trailing: IconButton(
                tooltip: 'Mediathek öffnen',
                onPressed: () => onOpenMedia(project),
                icon: const Icon(Icons.perm_media_outlined),
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 32),
      Text('Dein Workflow', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 14),
      const Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _WorkflowCard(
            number: '01',
            icon: Icons.auto_awesome_rounded,
            title: 'Grundlage finden',
            text: 'Logo und Bild hochladen. Farben und Struktur werden als Vorschlag vorbereitet.',
          ),
          _WorkflowCard(
            number: '02',
            icon: Icons.edit_note_rounded,
            title: 'Manual formen',
            text: 'Regeln, Beispiele und Anwendungen mit dem modularen Editor ausarbeiten.',
          ),
          _WorkflowCard(
            number: '03',
            icon: Icons.ios_share_rounded,
            title: 'Sicher ausgeben',
            text: 'Als HTML-Projekt oder PDF exportieren und kontrolliert weitergeben.',
          ),
        ],
      ),
    ],
  );
}

/// Projektbezogene Mediathek: Alle Requests laufen über die authentifizierte
/// Same-Origin-API. Storage-Keys oder reale Serverpfade erscheinen nie in der UI.
class _ProjectMediaSheet extends StatefulWidget {
  const _ProjectMediaSheet({
    required this.project,
    required this.repository,
    required this.assetPicker,
  });

  final ProjectSummary project;
  final ProjectRepository repository;
  final BrandAssetPicker assetPicker;

  @override
  State<_ProjectMediaSheet> createState() => _ProjectMediaSheetState();
}

class _ProjectMediaSheetState extends State<_ProjectMediaSheet> {
  List<MediaAsset> _assets = const [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final assets = await widget.repository.listAssets(widget.project.id);
      if (mounted) setState(() => _assets = assets);
    } on ProjectApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mediathek konnte nicht geladen werden.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(BrandAssetKind kind) async {
    setState(() => _uploading = true);
    try {
      final selection = await widget.assetPicker.pick(kind);
      if (selection == null) return;
      await widget.repository.uploadAsset(
        projectId: widget.project.id,
        kind: kind,
        selection: selection,
      );
      await _load();
    } on BrandAssetPickerException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on ProjectApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Upload nicht möglich. Bitte prüfe Format und Größe.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(MediaAsset asset) async {
    try {
      await widget.repository.deleteAsset(widget.project.id, asset.id);
      if (mounted) {
        setState(
          () => _assets = _assets
              .where((item) => item.id != asset.id)
              .toList(growable: false),
        );
      }
    } on ProjectApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datei konnte nicht entfernt werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .72,
    minChildSize: .48,
    maxChildSize: .92,
    builder: (context, controller) => Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD4D1D9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mediathek',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      widget.project.name,
                      style: const TextStyle(color: Color(0xFF686670)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<BrandAssetKind>(
                enabled: !_uploading,
                onSelected: _add,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: BrandAssetKind.logo,
                    child: Text('Logo hochladen'),
                  ),
                  PopupMenuItem(
                    value: BrandAssetKind.referenceImage,
                    child: Text('Bild hochladen'),
                  ),
                ],
                icon: _uploading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _assets.isEmpty
                ? const Center(
                    child: Text(
                      'Noch keine privaten Medien in diesem Projekt.',
                    ),
                  )
                : GridView.builder(
                    controller: controller,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .9,
                        ),
                    itemCount: _assets.length,
                    itemBuilder: (context, index) {
                      final asset = _assets[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                Uri.base.resolve(asset.contentUrl).toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    asset.kind == 'logo' ? 'Logo' : 'Bild',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: IconButton(
                                onPressed: () => _delete(asset),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.white,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _ProjectSlotCard extends StatelessWidget {
  const _ProjectSlotCard({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const description = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dein erster Projektslot wartet.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Starte mit einer Marke. Der Assistent erstellt dir eine editierbare, professionelle Ausgangsbasis.',
            style: TextStyle(color: Color(0xFFE9E9E9), height: 1.4),
          ),
        ],
      );
      final action = FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Projekt anlegen'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111114),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        ),
      );
      final compact = constraints.maxWidth < 560;

      return Container(
        constraints: const BoxConstraints(maxWidth: 980),
        padding: EdgeInsets.all(compact ? 22 : 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111114), Color(0xFF333333)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [description, const SizedBox(height: 20), action],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: description),
                  const SizedBox(width: 16),
                  action,
                ],
              ),
      );
    },
  );
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });
  final String number;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: 250,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFF8F8D96),
                fontWeight: FontWeight.w800,
              ),
            ),
            Icon(icon, color: const Color(0xFF111114)),
          ],
        ),
        const SizedBox(height: 28),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 7),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF686670),
            height: 1.45,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _AssistantWorkspace extends StatelessWidget {
  const _AssistantWorkspace({
    required this.logo,
    required this.referenceImage,
    required this.onAddMaterial,
  });

  final BrandAssetSelection? logo;
  final BrandAssetSelection? referenceImage;
  final VoidCallback onAddMaterial;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dein Projektassistent.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text(
              'Logo und Referenzbilder sind optional. Du kannst sie jederzeit hier ergänzen oder ersetzen.',
            ),
            const SizedBox(height: 24),
            if (logo != null || referenceImage != null) ...[
              _MaterialStatusRow(label: 'Logo', selection: logo),
              const SizedBox(height: 8),
              _MaterialStatusRow(
                label: 'Referenzbild',
                selection: referenceImage,
              ),
              const SizedBox(height: 20),
            ],
            FilledButton.icon(
              key: const Key('project.material.manage'),
              onPressed: onAddMaterial,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                logo == null && referenceImage == null
                    ? 'Markenmaterial ergänzen'
                    : 'Markenmaterial verwalten',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MaterialStatusRow extends StatelessWidget {
  const _MaterialStatusRow({required this.label, required this.selection});

  final String label;
  final BrandAssetSelection? selection;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        selection == null ? Icons.circle_outlined : Icons.check_circle,
        size: 18,
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          selection == null ? '$label noch nicht ausgewählt' : selection!.name,
        ),
      ),
    ],
  );
}

class _NewProjectSheet extends StatefulWidget {
  const _NewProjectSheet({
    required this.assetPicker,
    required this.initialStep,
    required this.initialLogo,
    required this.initialReferenceImage,
    required this.onMaterialChanged,
    required this.onCreateProject,
  });

  final BrandAssetPicker assetPicker;
  final int initialStep;
  final BrandAssetSelection? initialLogo;
  final BrandAssetSelection? initialReferenceImage;
  final void Function(BrandAssetKind, BrandAssetSelection?) onMaterialChanged;
  final Future<void> Function({
    required String name,
    required String company,
    required String description,
    required String fontFamily,
  })
  onCreateProject;

  @override
  State<_NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends State<_NewProjectSheet> {
  final _projectController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _fontFamily = 'Open Sans';
  late int _step;
  late BrandAssetSelection? _logo;
  late BrandAssetSelection? _referenceImage;
  BrandAssetKind? _pickingKind;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _logo = widget.initialLogo;
    _referenceImage = widget.initialReferenceImage;
  }

  @override
  void dispose() {
    _projectController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .78,
    minChildSize: .55,
    maxChildSize: .92,
    builder: (context, controller) => Container(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D1D9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _AssistantProgress(step: _step),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: controller,
              children: [_buildStep(context)],
            ),
          ),
          const SizedBox(height: 18),
          if (_step == 1) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('onboarding.skipMaterial'),
                onPressed: () => setState(() => _step = 2),
                child: const Text('Jetzt überspringen'),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step -= 1),
                  child: const Text('Zurück'),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _creating ? null : _continue,
                  child: Text(
                    _creating
                        ? 'Projekt wird gespeichert …'
                        : _step == 2
                        ? widget.initialStep == 1
                              ? 'Material übernehmen'
                              : 'Projektbasis erstellen'
                        : 'Weiter',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lass uns deine Marke kennenlernen.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese Angaben strukturieren dein Manual. Du kannst alles später ändern.',
            ),
            const SizedBox(height: 26),
            const _FormLabel('Wie heißt dein Projekt?'),
            TextField(
              controller: _projectController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('z. B. Markenmanual 2026'),
            ),
            const SizedBox(height: 18),
            const _FormLabel('Für welches Unternehmen?'),
            TextField(
              controller: _companyController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration('Firmenname'),
            ),
            const SizedBox(height: 18),
            const _FormLabel('Wofür steht die Marke?'),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 4,
              decoration: _inputDecoration(
                'Kurze Beschreibung, Zielgruppe oder Haltung',
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gib deiner Marke Material.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Logo und Referenzbild helfen bei der ersten Farb- und Stilrichtung. Die Dateien bleiben projektprivat.',
            ),
            const SizedBox(height: 26),
            _UploadHint(
              key: const Key('onboarding.logoUpload'),
              icon: Icons.add_photo_alternate_outlined,
              title: 'Logo hinzufügen',
              subtitle: 'PNG, JPG oder WebP · optional',
              selection: _logo,
              loading: _pickingKind == BrandAssetKind.logo,
              onPressed: () => _pickAsset(BrandAssetKind.logo),
            ),
            const SizedBox(height: 14),
            _UploadHint(
              key: const Key('onboarding.referenceUpload'),
              icon: Icons.image_outlined,
              title: 'Referenzbild hinzufügen',
              subtitle: 'PNG, JPG oder WebP · optional',
              selection: _referenceImage,
              loading: _pickingKind == BrandAssetKind.referenceImage,
              onPressed: () => _pickAsset(BrandAssetKind.referenceImage),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: Color(0xFF111114)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nach der Projektanlage werden Bilder verschlüsselt referenziert und ausschließlich über deine geschützte Projekt-Mediathek bereitgestellt.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deine editierbare Ausgangsbasis.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Für ${_companyController.text.trim().isEmpty ? 'deine Marke' : _companyController.text.trim()} wird eine ruhige, kontrastreiche Richtung vorbereitet.',
            ),
            const SizedBox(height: 26),
            const Text(
              'Vorgeschlagene Startpalette',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _ColorSwatch(color: Color(0xFF111114), label: 'Ink'),
                SizedBox(width: 10),
                _ColorSwatch(color: Color(0xFF555555), label: 'Grey'),
                SizedBox(width: 10),
                _ColorSwatch(color: Color(0xFFFFFFFF), label: 'White'),
                SizedBox(width: 10),
                _ColorSwatch(color: Color(0xFFF6F5F2), label: 'Canvas'),
              ],
            ),
            const SizedBox(height: 28),
            BrandTypographySelector(
              selectedFamily: _fontFamily,
              onChanged: (family) => setState(() => _fontFamily = family),
              onUploadInfo: _showFontUploadInfo,
            ),
            const SizedBox(height: 28),
            const Text(
              'Das wird vorbereitet',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _PreparedModule(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Markenkern, Logo und Farbsystem',
            ),
            const _PreparedModule(
              icon: Icons.text_fields_rounded,
              text: 'Typografie, Bildsprache und Anwendungen',
            ),
            const _PreparedModule(
              icon: Icons.view_carousel_outlined,
              text: 'Social-Media-Codex mit Vorlagenraster',
            ),
          ],
        );
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: const OutlineInputBorder(),
  );

  Future<void> _continue() async {
    if (_step == 0 && _projectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gib deinem Projekt zuerst einen Namen.')),
      );
      return;
    }
    if (_step < 2) {
      setState(() => _step += 1);
      return;
    }
    if (widget.initialStep == 1) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dein Markenmaterial ist für diese Sitzung vorgemerkt.',
          ),
        ),
      );
      return;
    }
    setState(() => _creating = true);
    try {
      await widget.onCreateProject(
        name: _projectController.text.trim(),
        company: _companyController.text.trim(),
        description: _descriptionController.text.trim(),
        fontFamily: _fontFamily,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '„${_projectController.text.trim()}“ wurde sicher gespeichert.',
          ),
        ),
      );
    } on ProjectApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Projekt konnte nicht gespeichert werden. Bitte versuche es später erneut.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _pickAsset(BrandAssetKind kind) async {
    setState(() => _pickingKind = kind);
    try {
      final selection = await widget.assetPicker.pick(kind);
      if (!mounted || selection == null) return;
      setState(() {
        if (kind == BrandAssetKind.logo) {
          _logo = selection;
        } else {
          _referenceImage = selection;
        }
      });
      widget.onMaterialChanged(kind, selection);
    } on BrandAssetPickerException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _pickingKind = null);
    }
  }

  void _showFontUploadInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Der sichere Font-Upload folgt als kostenpflichtige Einmalkauf-Erweiterung.',
        ),
      ),
    );
  }
}

class _AssistantProgress extends StatelessWidget {
  const _AssistantProgress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      3,
      (index) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${['Grundlage', 'Material', 'Start'][index]}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: index <= step
                      ? const Color(0xFF111114)
                      : const Color(0xFF96939C),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: index <= step
                      ? const Color(0xFF111114)
                      : const Color(0xFFE3E0E7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _UploadHint extends StatelessWidget {
  const _UploadHint({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selection,
    required this.loading,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final BrandAssetSelection? selection;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: selection == null ? title : '${selection!.name} ersetzen',
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selection == null
              ? const Color(0xFFD9D6DF)
              : const Color(0xFF111114),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF111114)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection?.name ?? title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selection == null ? subtitle : 'Zum Ersetzen anklicken',
                        style: const TextStyle(
                          color: Color(0xFF686670),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (selection != null)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ausgewählt',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Color(0xFF111114)),
                    ],
                  )
                else
                  const Icon(Icons.add_rounded, color: Color(0xFF111114)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: color == const Color(0xFFF6F5F2)
                ? Border.all(color: const Color(0xFFD9D6DF))
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _PreparedModule extends StatelessWidget {
  const _PreparedModule({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF111114)),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}
