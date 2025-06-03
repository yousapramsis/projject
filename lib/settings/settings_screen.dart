import 'package:flutter/material.dart';
import 'package:project_grad/Home/home_page.dart' show MyHomePage;
import 'package:project_grad/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChange;

  const SettingsScreen({
    Key? key,
    required this.currentLocale,
    required this.onLocaleChange,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.currentLocale;
  }

  void _changeLocale(bool isArabic) {
    final newLocale = isArabic ? const Locale('ar') : const Locale('en');
    setState(() {
      _currentLocale = newLocale;
    });
    widget.onLocaleChange(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    bool isArabic = _currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 100, 120, 240),
        title: Text(loc.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: Text(loc.language),
            trailing: Switch(
              value: isArabic,
              onChanged: (value) {
                _changeLocale(value);
              },
            ),
            subtitle: Text(isArabic ? 'العربية' : 'English'),
          ),
        ],
      ),
    );
  }
}
