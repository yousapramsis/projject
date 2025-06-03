import 'package:flutter/cupertino.dart' show Key;
import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        BuildContext,
        Widget,
        Directionality,
        Scaffold,
        BoxDecoration,
        Icon,
        EdgeInsets,
        SizedBox,
        TextStyle,
        Border,
        Alignment,
        LinearGradient,
        Container,
        Text,
        Icons,
        Navigator,
        IconButton,
        AppBar,
        Column,
        Padding,
        SingleChildScrollView,
        SafeArea,
        BorderRadius,
        RoundedRectangleBorder,
        Card,
        Colors,
        ListTileControlAffinity,
        CheckboxListTile,
        BorderSide,
        CrossAxisAlignment,
        ElevatedButton,
        MaterialPageRoute;
import 'package:project_grad/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'hypertension_test_page.dart' show HypertensionTestPage;

class HypertensionSymptomsScreen extends StatefulWidget {
  const HypertensionSymptomsScreen({Key? key}) : super(key: key);

  @override
  _HypertensionSymptomsScreenState createState() =>
      _HypertensionSymptomsScreenState();
}

class _HypertensionSymptomsScreenState
    extends State<HypertensionSymptomsScreen> {
  late Map<String, bool> symptoms;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    symptoms = {
      loc.hypertension_symptom_headache: false,
      loc.hypertension_symptom_fatigue: false,
      loc.hypertension_symptom_vision: false,
      loc.hypertension_symptom_chest_pain: false,
      loc.hypertension_symptom_breathing: false,
      loc.hypertension_symptom_heartbeat: false,
      loc.hypertension_symptom_blood_urine: false,
      loc.hypertension_symptom_pounding: false,
      loc.hypertension_symptom_nosebleeds: false,
    };
  }

  int get symptomCount =>
      symptoms.values.where((isChecked) => isChecked).length;
  bool get showWarning => symptomCount < 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
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
          title: Text(loc.hypertension_symptoms_appbar),
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
                    _buildSymptomsCard(loc),
                    const SizedBox(height: 20),
                    _buildActionButtons(loc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(AppLocalizations loc) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.bloodtype,
              size: 50,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 20),
            Text(
              loc.hypertension_symptoms_title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              loc.hypertension_symptoms_instruction,
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
            _buildStatusBox(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCheckboxes() {
    return Column(
      children: symptoms.keys.map((symptom) {
        return CheckboxListTile(
          title: Text(
            symptom,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D3A),
            ),
          ),
          value: symptoms[symptom],
          activeColor: const Color(0xFF6C63FF),
          checkColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) {
            setState(() {
              symptoms[symptom] = value ?? false;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusBox(AppLocalizations loc) {
    if (showWarning) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F0),
          borderRadius: BorderRadius.circular(15),
          border: const Border(
            left: BorderSide(
              color: Color(0xFFFF9E80),
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.hypertension_symptoms_warning_title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE64A19),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.hypertension_symptoms_warning_desc,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A5A5A),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF),
          borderRadius: BorderRadius.circular(15),
          border: const Border(
            left: BorderSide(
              color: Color(0xFF6C63FF),
              width: 4,
            ),
          ),
        ),
        child: Text(
          loc.hypertension_symptoms_selected(symptomCount),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D2D3A),
            height: 1.5,
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HypertensionTestPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        showWarning
            ? loc.hypertension_symptoms_check_anyway
            : loc.hypertension_symptoms_continue,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
