/// Test- und Nicht-Web-Fallback. Die produktive Anwendung verwendet die
/// Web-Implementierung und speichert ausschließlich die Auswahl selbst.
bool hasSavedCookieChoice() => false;

void saveNecessaryCookieChoice() {}

void openExternalUrl(String url) {}
