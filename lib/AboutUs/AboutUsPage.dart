import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Introduction
                _buildAppIntro(),
                const SizedBox(height: 30),

                // Supervisors Section
                _buildSupervisorSection(),
                const SizedBox(height: 30),

                // Co-supervisor Section
                _buildCoSupervisorSection(),
                const SizedBox(height: 30),

                // Team Members Section
                _buildTeamSection(),
                const SizedBox(height: 30),

                // Disclaimer
                _buildDisclaimerSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services,
              size: 50, color: Color(0xFF6C63FF)),
          const SizedBox(height: 15),
          const Text(
            'Multiple Disease Prediction',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D3A),
          ),),
          const SizedBox(height: 10),
          const Text(
            'Health Friendly App\n',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5A5A5A)),),
          const Text(
            'Empowering early detection of chronic conditions through advanced predictive analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorSection() {
    return Column(
      children: [
        const SectionTitle(title: 'Supervised By'),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(
              child: SupervisorInfoCard(
                name: 'Dr. Mohamed Saeed',
                title: 'Head of Internal Medicine, O6U',
                icon: Icons.medical_services,
                color: Color(0xFFFF7D7D),),),
            SizedBox(width: 15),
            Expanded(
              child: SupervisorInfoCard(
                  name: 'Dr. Samy ElMokadem',
                  title: 'Computer Science Specialist, O6U',
                  icon: Icons.computer,
                  color: Color(0xFF7D8AFF)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoSupervisorSection() {
    return Column(
      children: [
        const SectionTitle(title: 'Technical Lead'),
        const SizedBox(height: 20),
        const SupervisorInfoCard(
            name: 'Marco ELKess Mallak',
            title: 'Assistant Engineer',
            icon: Icons.engineering,
            color: Color(0xFF7DFF9D)),
      ],
    );
  }

  Widget _buildTeamSection() {
    return Column(
      children: [
        const SectionTitle(title: 'Development Team'),
        const SizedBox(height: 20),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: const [
            TeamMemberCard(
                name: 'Yousap Ramsis',
                id: '212103743',
                color: Color(0xFFFFB4B4)),
            TeamMemberCard(
                name: 'Mena Nabil',
                id: '212103454',
                color: Color(0xFFB4BDFF)),
            TeamMemberCard(
                name: 'Ahmed Mohamed',
                id: '212103755',
                color: Color(0xFF7DFF9D)),
            TeamMemberCard(
                name: 'Sara Mahmoud',
                id: '212103766',
                color: Color(0xFFFFD700)),
            TeamMemberCard(
                name: 'Omar Ali',
                id: '212103777',
                color: Color(0xFFFF69B4)),
            TeamMemberCard(
                name: 'Fatma Hassan',
                id: '212103788',
                color: Color(0xFF20B2AA)),
            TeamMemberCard(
                name: 'Khaled Ibrahim',
                id: '212103799',
                color: Color(0xFFDA70D6)),
            TeamMemberCard(
                name: 'Lina Samir',
                id: '212103800',
                color: Color(0xFF32CD32)),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB2EBF2), width: 2),
      ),
      child: const DisclaimerText(),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A90E2),
        letterSpacing: 1.2,
      ),
    );
  }
}

class SupervisorInfoCard extends StatelessWidget {
  final String name;
  final String title;
  final IconData icon;
  final Color color;

  const SupervisorInfoCard({
    required this.name,
    required this.title,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 15),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              height: 1.4),
          ),
        ],
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String id;
  final Color color;

  const TeamMemberCard({
    required this.name,
    required this.id,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: $id',
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class DisclaimerText extends StatelessWidget {
  const DisclaimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This application is for educational and informational purposes only and should not be considered as a substitute for professional medical advice. Always consult with a qualified healthcare provider for any health concerns.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
        height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}