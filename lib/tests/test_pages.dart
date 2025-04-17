import 'package:flutter/material.dart';

class DiabetesTestPage extends StatelessWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Use ListView for scrolling if content overflows
          children: [
            Text(
              'Diabetes Risk Factors',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DiabetesParameterCard(
              title: 'Fasting Blood Sugar',
              description: 'Normal range: 70-100 mg/dL',
              icon: Icons.bloodtype,
            ),
            const SizedBox(height: 12),
            DiabetesParameterCard(
              title: 'HbA1c Level',
              description: 'Normal range: Below 5.7%',
              icon: Icons.analytics,
            ),
            const SizedBox(height: 12),
            DiabetesParameterCard(
              title: 'Family History',
              description: 'Assess your family history of diabetes.',
              icon: Icons.family_restroom,
            ),
            // Add more parameters as needed
          ],
        ),
      ),
    );
  }
}

class HypertensionTestPage extends StatelessWidget {
  const HypertensionTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypertension Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Hypertension Risk Factors',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            HypertensionParameterCard(
              title: 'Blood Pressure Reading',
              description: 'Normal: Less than 120/80 mmHg',
              icon: Icons.monitor_heart,
            ),
            const SizedBox(height: 12),
            HypertensionParameterCard(
              title: 'Age',
              description: 'Risk increases with age',
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            HypertensionParameterCard(
              title: 'Lifestyle',
              description: 'Diet, exercise, smoking habits',
              icon: Icons.fitness_center,
            ),
            // Add more parameters as needed
          ],
        ),
      ),
    );
  }
}

class HeartDiseasesTestPage extends StatelessWidget {
  const HeartDiseasesTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Diseases Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Heart Disease Risk Factors',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            HeartParameterCard(
              title: 'Cholesterol Levels',
              description: 'HDL, LDL, Total Cholesterol',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 12),
            HeartParameterCard(
              title: 'Blood Pressure',
              description: 'Systolic and Diastolic readings',
              icon: Icons.favorite,
            ),
            const SizedBox(height: 12),
            HeartParameterCard(
              title: 'Smoking History',
              description: 'Current or past smoker',
              icon: Icons.smoking_rooms,
            ),
            // Add more parameters as needed
          ],
        ),
      ),
    );
  }
}

// Custom Card Widgets for each test
class DiabetesParameterCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const DiabetesParameterCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HypertensionParameterCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const HypertensionParameterCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeartParameterCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const HeartParameterCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}