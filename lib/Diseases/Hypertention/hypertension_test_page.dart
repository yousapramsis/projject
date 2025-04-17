// hypertension_test_page.dart
import 'package:flutter/material.dart';

class HypertensionTestPage extends StatelessWidget {
  const HypertensionTestPage({Key? key}) : super(key: key);

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
        title: const Text('Hypertension Test',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Hypertension Risk Factors',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(
                            0xFF2D2D3A), // Match main page text color
                      ),
                ),
                const SizedBox(height: 16),
                const HypertensionParameterCard(
                  title: 'Blood Pressure Reading',
                  description: 'Normal: Less than 120/80 mmHg',
                  icon: Icons.monitor_heart,
                ),
                const SizedBox(height: 12),
                const HypertensionParameterCard(
                  title: 'Age',
                  description: 'Risk increases with age',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                const HypertensionParameterCard(
                  title: 'Lifestyle',
                  description: 'Diet, exercise, smoking habits',
                  icon: Icons.fitness_center,
                ),
                // Add more parameters as needed
              ],
            ),
          ),
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