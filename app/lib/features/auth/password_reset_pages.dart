import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Fordert einen Einmal-Link an. Die Antwort bleibt absichtlich unabhängig
/// davon gleich, ob die E-Mail-Adresse im System existiert.
class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  State<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  final _email = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() => _sending = true);
    try {
      await http.post(
        Uri.base.resolve('api/auth/request-password-reset'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email.text}),
      );
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _sent = true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: _sent
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'E-Mail prüfen.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Falls ein Konto zu dieser Adresse existiert, wurde ein zeitlich begrenzter Link versendet.',
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Zurück zur Anmeldung'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kennwort zurücksetzen.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Wir senden dir einen zeitlich begrenzten Link an deine hinterlegte E-Mail-Adresse.',
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _email,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail-Adresse',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _sending ? null : _request,
                          child: Text(
                            _sending
                                ? 'Link wird angefordert …'
                                : 'Reset-Link anfordern',
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}

/// Verarbeitet nur das kurzlebige Einmal-Token aus der Reset-E-Mail.
class PasswordResetConfirmPage extends StatefulWidget {
  const PasswordResetConfirmPage({super.key, required this.token});

  final String token;

  @override
  State<PasswordResetConfirmPage> createState() =>
      _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends State<PasswordResetConfirmPage> {
  final _password = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.base.resolve('api/auth/reset-password'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': widget.token,
          'new_password': _password.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      } else {
        setState(() => _error = 'Der Link ist ungültig oder abgelaufen.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Der Dienst ist gerade nicht erreichbar.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Neues Kennwort festlegen.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mindestens 14 Zeichen mit Groß- und Kleinbuchstabe sowie einer Zahl.',
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Neues Kennwort',
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFF8D0000)),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _reset,
                    child: Text(
                      _sending ? 'Wird gespeichert …' : 'Kennwort speichern',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
