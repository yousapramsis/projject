import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:project_grad/l10n/app_localizations.dart';

class PositiveResultPage extends StatelessWidget {
  const PositiveResultPage({Key? key}) : super(key: key);

  final String _mapsUrl =
      "https://www.google.com/maps/search/?api=1&query=29.9787527,30.9502569";

  Future<void> _launchMapsUrl(BuildContext context) async {
    final Uri uri = Uri.parse(_mapsUrl);
    final loc = AppLocalizations.of(context)!;

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showErrorSnackbar(context, loc.map_error);
      }
    } catch (e) {
      _showErrorSnackbar(context, '${loc.error_occurred}: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.important_health_advice),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F0), Color(0xFFFFE0E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Directionality(
            textDirection:
                (loc.isRtl == true) ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 80, color: Colors.redAccent),
                const SizedBox(height: 25),
                Text(
                  loc.hypertension_warning,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  loc.hypertension_description,
                  style: TextStyle(
                      fontSize: 17, color: Colors.grey[800], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Text(
                  loc.medical_advice,
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  loc.recommended_hospital,
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: Text(loc.get_location,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                  onPressed: () => _launchMapsUrl(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
