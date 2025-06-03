import 'package:flutter/material.dart';
import 'package:project_grad/l10n/app_localizations.dart' show AppLocalizations;
import 'heart_diseases_test_page.dart';

class HeartDiseaseSymptomsScreen extends StatefulWidget {
  const HeartDiseaseSymptomsScreen({Key? key}) : super(key: key);

  @override
  _HeartDiseaseSymptomsScreenState createState() =>
      _HeartDiseaseSymptomsScreenState();
}

class _HeartDiseaseSymptomsScreenState
    extends State<HeartDiseaseSymptomsScreen> {
  Map<String, bool> symptoms = {};

  @override
  void initState() {
    super.initState();
    // Delay localization fetching until context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context)!;
      setState(() {
        symptoms = {
          loc.symptom_chest_pain: false,
          loc.symptom_shortness_breath: false,
          loc.symptom_neck_pain: false,
          loc.symptom_limb_pain: false,
          loc.symptom_fluttering: false,
          loc.symptom_fatigue: false,
          loc.symptom_dizziness: false,
          loc.symptom_swelling: false,
          loc.symptom_irregular_heartbeat: false,
        };
      });
    });
  }

  int get symptomCount =>
      symptoms.values.where((isChecked) => isChecked).length;
  bool get showWarning => symptomCount < 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.heart_disease_symptoms),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSymptomsCard(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 50, color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.heart_disease_symptoms_check,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.symptoms_check,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5A5A5A),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildSymptomsCheckboxes(),
            const SizedBox(height: 20),
            _buildStatusBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCheckboxes() {
    return Column(
      children: symptoms.keys.map((symptom) {
        return CheckboxListTile(
          title: Text(symptom),
          value: symptoms[symptom],
          activeColor: const Color(0xFF6C63FF),
          checkColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) {
            setState(() => symptoms[symptom] = value ?? false);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusBox() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showWarning ? _buildWarningBox() : _buildRecommendationBox(),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      key: const ValueKey('warning'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(15),
        border:
            const Border(left: BorderSide(color: Color(0xFFFF9E80), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.no_heart_disease_warning,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE64A19),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.result_instruction,
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

  Widget _buildRecommendationBox() {
    return Container(
      key: const ValueKey('recommendation'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(15),
        border:
            const Border(left: BorderSide(color: Color(0xFF6C63FF), width: 4)),
      ),
      child: Text(
        'You\'ve selected $symptomCount symptoms. It\'s recommended to take a heart test.',
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D2D3A),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HeartDiseasesTestPage()),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        showWarning
            ? AppLocalizations.of(context)!.check_anyway
            : AppLocalizations.of(context)!.continue_to_test,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
