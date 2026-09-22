import 'package:web/web.dart' as web;

const _themeModeKey = 'ci_builder_theme_mode_v1';

/// Speichert ausschließlich die Darstellungspräferenz auf dem aktuellen Gerät.
/// Es werden weder Kontodaten noch eine Kennung an den Server übertragen.
bool loadDarkModePreference() {
  try {
    return web.window.localStorage.getItem(_themeModeKey) == 'dark';
  } catch (_) {
    // Private Browsermodi können Local Storage sperren. Dann bleibt Light Mode
    // der sichere, vorhersehbare Standard.
    return false;
  }
}

void saveDarkModePreference(bool enabled) {
  try {
    web.window.localStorage.setItem(_themeModeKey, enabled ? 'dark' : 'light');
  } catch (_) {
    // Die Anwendung bleibt auch ohne lokalen Speicher vollständig nutzbar.
  }
}
