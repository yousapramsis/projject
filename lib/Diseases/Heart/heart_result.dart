import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class PositiveResultPage extends StatelessWidget {
  const PositiveResultPage({Key? key}) : super(key: key);

  // Simplified Google Maps link using coordinates
  final String _mapsUrl = "https://www.google.com/maps/search/?api=1&query=29.9787527,30.9502569";

  // Launch the URL in external maps app
  Future<void> _launchMapsUrl(BuildContext context) async {
    final Uri uri = Uri.parse(_mapsUrl);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (kDebugMode) {
          print('launchUrl returned false.');
        }
        _showErrorSnackbar(context, 'Could not open map location.');
      } else {
        if (kDebugMode) {
          print('Map launched successfully.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching map: $e');
      }
      _showErrorSnackbar(context, 'An error occurred: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Health Advice', style: TextStyle(color: Colors.white)),
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
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.redAccent,
              ),
              
              const SizedBox(height: 25),
              const Text(
                'Warning: Potential Heart diseases Risk Detected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Heart diseases are serious conditions that require prompt medical attention. Early diagnosis and management are crucial for preventing complications.',
                style: TextStyle(fontSize: 17, color: Colors.grey[800], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Text(
                'We strongly advise you to consult a healthcare professional immediately. Please visit a hospital for further testing and guidance.',
                style: TextStyle(fontSize: 17, color: Colors.grey[800], fontWeight: FontWeight.w500, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Here is a recommended hospital that can assist you:',
                style: TextStyle(fontSize: 17, color: Colors.grey[700], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Get Hospital Location', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () => _launchMapsUrl(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
