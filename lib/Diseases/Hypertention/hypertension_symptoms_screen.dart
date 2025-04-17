import 'package:flutter/material.dart';
import 'hypertension_test_page.dart';

class HypertensionSymptomsScreen extends StatefulWidget {
  const HypertensionSymptomsScreen({Key? key}) : super(key: key);

  @override
  _HypertensionSymptomsScreenState createState() => _HypertensionSymptomsScreenState();
}

class _HypertensionSymptomsScreenState extends State<HypertensionSymptomsScreen> {
  Map<String, bool> symptoms = {
    'Severe headaches': false,
    'Fatigue or confusion': false,
    'Vision problems': false,
    'Chest pain': false,
    'Difficulty breathing': false,
    'Irregular heartbeat': false,
    'Blood in the urine': false,
    'Pounding in chest, neck, or ears': false,
    'Nosebleeds': false,
  };

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
        title: const Text('Hypertension Symptoms'),
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
            const Text(
              'Hypertension Symptoms Check',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D3A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check any symptoms you\'ve experienced recently:',
              style: TextStyle(
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

  Widget _buildStatusBox() {
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
          children: const [
            Text(
              'Most likely you do not have hypertension.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE64A19),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'You\'ve selected fewer than 1 symptoms. If you still want to check, use the button below.',
              style: TextStyle(
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
          'You\'ve selected $symptomCount symptoms. It\'s recommended to take a hypertension test.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D2D3A),
            height: 1.5,
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons() {
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
        showWarning ? 'Check Anyway' : 'Continue to Test',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
