class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'hello': 'Hello',
      'welcome': 'Welcome',
    },
    'ar': {
      'hello': 'مرحبا',
      'welcome': 'أهلا بك',
    },
  };

  static String get(String key, String langCode) {
    return localizedValues[langCode]?[key] ?? key;
  }
}
