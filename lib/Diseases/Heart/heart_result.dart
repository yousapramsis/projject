import 'package:flutter/material.dart';
import 'package:project_grad/l10n/app_localizations.dart' show AppLocalizations;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class PositiveResultPage extends StatelessWidget {
  const PositiveResultPage({Key? key}) : super(key: key);

  // Simplified Google Maps link using coordinates
  final String _mapsUrl =
      "https://www.google.com/maps/search/?api=1&query=29.9787527,30.9502569";

  // Launch the URL in external maps app
  Future<void> _launchMapsUrl(BuildContext context) async {
    final Uri uri = Uri.parse(_mapsUrl);
    final loc = AppLocalizations.of(context)!;

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (kDebugMode) {
          print('launchUrl returned false.');
        }
        _showErrorSnackbar(context, loc.map_error);
      } else {
        if (kDebugMode) {
          print('Map launched successfully.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching map: $e');
      }
      _showErrorSnackbar(context, '${loc.error_occurred}: $e');
    }
  }

  // Display a red error message
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
    // Check if the app is in RTL mode
    final bool isRtl = loc.isRtl == "true";

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.important_health_advice,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F0), Color(0xFFFFE0E0)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Container with the design specs from the image
              Container(
                width: 382,
                height: 315,
                margin: const EdgeInsets.only(top: 181, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.19),
                      offset: const Offset(0, 4),
                      blurRadius: 13.3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 60,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.heart_disease_risk_warning,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        loc.heart_disease_warning_text,
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey[800], height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Text(
                loc.medical_consult_advice,
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),
              Text(
                loc.hospital_recommendation_heart,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: Text(loc.get_hospital_location,
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () => _launchMapsUrl(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
