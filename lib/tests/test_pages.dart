import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_grad/l10n/app_localizations.dart' show AppLocalizations;

class DiabetesTestPage extends StatelessWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.diabetes_symptoms),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.diabetes_risk_assess,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(loc.symptoms_check),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCheckbox(loc.frequent_urination),
                  _buildCheckbox(loc.excessive_thirst),
                  _buildCheckbox(loc.unexplained_weight_loss),
                  _buildCheckbox(loc.extreme_hunger),
                  _buildCheckbox(loc.blurred_vision),
                  _buildCheckbox(loc.increased_fatigue),
                  _buildCheckbox(loc.slow_healing),
                  _buildCheckbox(loc.frequent_infections),
                  _buildCheckbox(loc.numbness),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(loc.result_message),
            Text(loc.result_instruction),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(loc.check_risk),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: false,
      onChanged: (bool? value) {},
    );
  }
}

class HypertensionTestPage extends StatelessWidget {
  const HypertensionTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.hypertension_symptoms),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.hypertension_symptoms,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(loc.symptoms_check),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCheckbox(loc.severe_headaches),
                  _buildCheckbox(loc.fatigue_confusion),
                  _buildCheckbox(loc.vision_problems),
                  _buildCheckbox(loc.chest_pain),
                  _buildCheckbox(loc.difficulty_breathing),
                  _buildCheckbox(loc.irregular_heartbeat),
                  _buildCheckbox(loc.blood_urine),
                  _buildCheckbox(loc.pounding),
                  _buildCheckbox(loc.nosebleeds),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(loc.check_risk),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: false,
      onChanged: (bool? value) {},
    );
  }
}

class HeartDiseaseTestPage extends StatelessWidget {
  const HeartDiseaseTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.heart_disease_symptoms),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.heart_disease_risk_assess,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(loc.symptoms_check),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCheckbox(loc.chest_pain_discomfort),
                  _buildCheckbox(loc.shortness_breath),
                  _buildCheckbox(loc.neck_jaw_pain),
                  _buildCheckbox(loc.limb_pain_numbness),
                  _buildCheckbox(loc.fluttering_chest),
                  _buildCheckbox(loc.increased_fatigue),
                  _buildCheckbox(loc.lightheadedness),
                  _buildCheckbox(loc.swelling),
                  _buildCheckbox(loc.irregular_heartbeat),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text(loc.check_risk),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: false,
      onChanged: (bool? value) {},
    );
  }
}
