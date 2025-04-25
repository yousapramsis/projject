import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_grad/Diseases/Heart/heart_symptoms_screen.dart';
import 'package:project_grad/Home/widgets/diseases_card.dart';
import '../Diseases/Diabetes/diabetes_symptoms_screen.dart';
import '../AboutUs/AboutUsPage.dart';
import '../Diseases/Hypertention/hypertension_symptoms_screen.dart';
import '../Diseases/Diabetes/diabetes_symptoms_screen.dart';
import '../Diseases/Heart/heart_diseases_test_page.dart';
import '../Diseases/Hypertention/hypertension_test_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  final List<String> _healthAdvices = [
    "Stay hydrated by drinking plenty of water.",
    "Eat a balanced diet rich in fruits and vegetables.",
    "Exercise regularly to maintain a healthy weight.",
    "Get enough sleep each night.",
    "Manage stress through relaxation techniques.",
    "Limit your intake of processed foods and sugary drinks.",
    "Avoid smoking and excessive alcohol consumption.",
    "Get regular checkups with your doctor.",
    "Maintain a healthy social life and strong relationships.",
    "Practice good hygiene to prevent infections.",
    "It's best to avoid animal fats for a healthier lifestyle",
    "Include more plant-based foods in your diet for better health.",
  ];
  final List<String> _slideImages = [
    'assets/assets/slide1.png', // Replace with your actual image paths
    'assets/assets/slide2.png',
    'assets/assets/slide3.png',
    'assets/assets/slide4.png',
    'assets/assets/slide5.png',
    'assets/assets/slide6.png',
    'assets/assets/slide7.png',
    'assets/assets/slide8.png',
    'assets/assets/slide9.png',
    'assets/assets/slide10.png',
    'assets/assets/slide11.png',
    'assets/assets/slide12.png',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _slideImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first slide
      }
      // Animate to the next page.  Use animateToPage for smooth scrolling.
      if (_pageController.hasClients) {
        // Check if the controller is attached
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease, // Smooth animation
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(widget.title),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            ),
          ),
        ],
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
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slideImages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page; // Update current page index
                    });
                  },
                  itemBuilder: (context, index) {
                    return buildSlideItem(index); // Use the helper method
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(40)),
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
                    const Text(
                      'Health Assessments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          DiseaseCard(
                            title: 'Diabetes',
                            icon: Icons.bloodtype,
                            color1: const Color.fromARGB(255, 228, 235, 141),
                            color2: const Color.fromARGB(255, 176, 194, 76),
                            route:
                                DiabetesSymptomsScreen(), // Route to symptoms screen first
                          ),
                          const DiseaseCard(
                            title: 'Hypertension',
                            icon: Icons.monitor_heart,
                            color1: Color.fromARGB(255, 71, 85, 209),
                            color2: Color.fromARGB(255, 66, 86, 231),
                            route: HypertensionSymptomsScreen(),
                          ),
                          const DiseaseCard(
                            title: 'Heart Health',
                            icon: Icons.favorite,
                            color1: Color(0xFFF44336),
                            // Red Color for Heart Health
                            color2: Color(0xFFE57373),
                            // Lighter Red
                            route: HeartDiseaseSymptomsScreen(),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 

  // Helper method to build each slide item
  Widget buildSlideItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_slideImages[index],
              height: 200), // Adjust height as needed
          const SizedBox(height: 30),
          Text(
            _healthAdvices[index],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D3A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          // Optional: Add "next/previous" indicators or dots here.
        ],
      ),
    );
  }
}
