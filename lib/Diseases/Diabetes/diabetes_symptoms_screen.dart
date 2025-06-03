import 'package:flutter/material.dart';
import 'package:project_grad/l10n/app_localizations.dart';
import 'diabetes_test_page.dart'; // Make sure this path is correct

class DiabetesSymptomsScreen extends StatefulWidget {
  const DiabetesSymptomsScreen({Key? key}) : super(key: key);

  @override
  State<DiabetesSymptomsScreen> createState() => _DiabetesSymptomsScreenState();
}

class _DiabetesSymptomsScreenState extends State<DiabetesSymptomsScreen> {
  // These keys must match the keys in your .arb files and _getSymptomText method
  final List<String> _symptomKeys = [
    'frequent_urination',
    'excessive_thirst',
    'unexplained_weight_loss',
    'extreme_hunger',
    'blurred_vision',
    'increased_fatigue',
    'slow_healing',
    'frequent_infections',
    'numbness',
  ];

  // Internal state for checkboxes, mapping internal key to boolean (checked state)
  Map<String, bool> symptomsState = {};

  @override
  void initState() {
    super.initState();
    // Initialize the state map for checkboxes
    symptomsState = {for (var key in _symptomKeys) key: false};
  }

  int get symptomCount =>
      symptomsState.values.where((checked) => checked).length;
  bool get showWarning => symptomCount < 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // Handle case where localization might not be ready
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows gradient to extend behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(loc.diabetes_symptoms,
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensures other icons are white
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSymptomsCard(loc),
                const SizedBox(height: 20),
                _buildActionButton(loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(AppLocalizations loc) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.bloodtype,
                size: 50, color: Color(0xFF6C63FF)), // Represents Diabetes
            const SizedBox(height: 20),
            Text(
              loc.diabetes_symptoms, // Localized title
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              loc.symptoms_check, // Localized instruction
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5A5A5A),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildSymptomsCheckboxes(loc),
            const SizedBox(height: 20),
            _buildStatusBox(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCheckboxes(AppLocalizations loc) {
    return Column(
      children: _symptomKeys.map((key) {
        return CheckboxListTile(
          title: Text(
            _getSymptomText(loc, key), // Get localized symptom text
            style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D3A)),
          ),
          value: symptomsState[key], // Use the state map
          activeColor: const Color(0xFF6C63FF),
          checkColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) {
            setState(() =>
                symptomsState[key] = value ?? false); // Update the state map
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusBox(AppLocalizations loc) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Example transition: fade and scale
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: showWarning ? _buildWarningBox(loc) : _buildRecommendationBox(loc),
    );
  }

  Widget _buildWarningBox(AppLocalizations loc) {
    return Container(
      key: const ValueKey('warningBox'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF3F0), // Light orange/red background for warning
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          left: BorderSide(color: Color(0xFFFF9E80), width: 4), // Accent border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.result_message, // Localized message for likely no diabetes
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE64A19), // Darker orange/red text
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.result_instruction, // Localized instruction if few symptoms selected
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A5A5A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBox(AppLocalizations loc) {
    // Correctly use the localization method with the placeholder
    final String resultText =
        loc.symptoms_selected_count(symptomCount.toString());

    return Container(
      key: const ValueKey('recommendationBox'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0F8FF), // Light blue background for recommendation
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          left: BorderSide(color: Color(0xFF6C63FF), width: 4), // Accent border
        ),
      ),
      child: Text(
        resultText, // Display the formatted localized string
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D2D3A),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(AppLocalizations loc) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          // Pass the selected symptoms to the test page if needed by its constructor
          // For example: MaterialPageRoute(builder: (_) => DiabetesTestPage(symptoms: symptomsState)),
          MaterialPageRoute(builder: (_) => const DiabetesTestPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF6C63FF), // Main action color
        foregroundColor: Colors.white, // Text color for the button
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Text(
        showWarning
            ? loc.check_anyway
            : loc.continue_test, // Localized button text
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper to get localized text for a given symptom key
  String _getSymptomText(AppLocalizations loc, String key) {
    switch (key) {
      case 'frequent_urination':
        return loc.frequent_urination;
      case 'excessive_thirst':
        return loc.excessive_thirst;
      case 'unexplained_weight_loss':
        return loc.unexplained_weight_loss;
      case 'extreme_hunger':
        return loc.extreme_hunger;
      case 'blurred_vision':
        return loc.blurred_vision;
      case 'increased_fatigue':
        return loc.increased_fatigue;
      case 'slow_healing':
        return loc.slow_healing;
      case 'frequent_infections':
        return loc.frequent_infections;
      case 'numbness':
        return loc.numbness;
      default:
        // Fallback, though ideally all keys should be covered
        return key.replaceAll('_', ' ').capitalizeFirstLetter();
    }
  }
}

// Helper extension for capitalizing the first letter (optional, for fallback)
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
