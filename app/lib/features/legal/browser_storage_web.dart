import 'package:web/web.dart' as web;

const _cookieChoiceKey = 'ci_builder_cookie_choice_v1';

bool hasSavedCookieChoice() =>
    web.window.localStorage.getItem(_cookieChoiceKey) == 'necessary';

void saveNecessaryCookieChoice() =>
    web.window.localStorage.setItem(_cookieChoiceKey, 'necessary');

void openExternalUrl(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
