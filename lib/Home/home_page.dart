import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_grad/settings/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../AboutUs/AboutUsPage.dart';
import 'widgets/diseases_card.dart';
import '../Diseases/Diabetes/diabetes_symptoms_screen.dart';
import '../Diseases/Hypertention/hypertension_symptoms_screen.dart';
import '../Diseases/Heart/heart_symptoms_screen.dart';

class MyHomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Locale currentLocale;

  const MyHomePage({
    Key? key,
    required this.onLocaleChange,
    required this.currentLocale,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPage = 0;
  late Locale _locale; // Add local locale state
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> _adviceKeys = [
    'advice_hydration',
    'advice_balanced_diet',
    'advice_exercise',
    'sleep_advice',
    'advice_stress',
    'advice_processed_foods',
    'advice_smoking',
    'advice_checkups',
    'advice_social_life',
    'advice_hygiene',
    'advice_animal_fats',
    'advice_plant_based',
  ];

  final List<String> _slideImages = [
    'assets/assets/slide1.png',
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
    _locale = widget.currentLocale; // Initialize local locale state
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      int nextPage = (_currentPage + 1) % _slideImages.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
      _currentPage = nextPage;
    });
  }

  void _updateLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale; // Update local locale state
    });
    widget.onLocaleChange(newLocale); // Notify parent
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
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
        title: Text(loc.app_title),
        actions: [
          IconButton(
            tooltip: 'About Us',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            ),
          ),
          IconButton(
            tooltip: loc.settings,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    currentLocale: _locale, // Use local locale state
                    onLocaleChange: _updateLocale, // Pass update function
                  ),
                ),
              );
            },
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
                    if (mounted) {
                      setState(() => _currentPage = page);
                    }
                  },
                  itemBuilder: (context, index) => buildSlideItem(index, loc),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.health_assessments,
                      style: const TextStyle(
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
                          DiseaseCard(
                            title: loc.diabetes,
                            icon: Icons.bloodtype,
                            color1: const Color.fromARGB(255, 245, 199, 100),
                            color2: const Color.fromARGB(255, 238, 160, 40),
                            route: DiabetesSymptomsScreen(),
                          ),
                          const SizedBox(width: 15),
                          DiseaseCard(
                            title: loc.hypertension,
                            icon: Icons.monitor_heart,
                            color1: const Color.fromARGB(255, 100, 120, 240),
                            color2: const Color.fromARGB(255, 66, 86, 231),
                            route: HypertensionSymptomsScreen(),
                          ),
                          const SizedBox(width: 15),
                          DiseaseCard(
                            title: loc.heart_health,
                            icon: Icons.favorite,
                            color1: const Color(0xFFF44336),
                            color2: const Color(0xFFE57373),
                            route: HeartDiseaseSymptomsScreen(),
                          ),
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

  Widget buildSlideItem(int index, AppLocalizations loc) {
    if (index < 0 ||
        index >= _slideImages.length ||
        index >= _adviceKeys.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              _slideImages[index],
              fit: BoxFit.contain,
              width: 350,
              height: 350,
            ),
          ),
          //const SizedBox(height: 10),
          Text(
            _getAdviceText(loc, _adviceKeys[index]),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF33334A),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _getAdviceText(AppLocalizations loc, String key) {
    switch (key) {
      case 'advice_hydration':
        return loc.advice_hydration;
      case 'advice_balanced_diet':
        return loc.advice_balanced_diet;
      case 'advice_exercise':
        return loc.advice_exercise;
      case 'sleep_advice':
        return loc.sleep_advice;
      case 'advice_stress':
        return loc.advice_stress;
      case 'advice_processed_foods':
        return loc.advice_processed_foods;
      case 'advice_smoking':
        return loc.advice_smoking;
      case 'advice_checkups':
        return loc.advice_checkups;
      case 'advice_social_life':
        return loc.advice_social_life;
      case 'advice_hygiene':
        return loc.advice_hygiene;
      case 'advice_animal_fats':
        return loc.advice_animal_fats;
      case 'advice_plant_based':
        return loc.advice_plant_based;
      default:
        print("Warning: Missing advice key localization: $key");
        return key;
    }
  }
}
