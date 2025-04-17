// heart_disease_test_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HeartDiseasesTestPage extends StatefulWidget {
  const HeartDiseasesTestPage({Key? key}) : super(key: key);

  @override
  _HeartDiseaseTestPageState createState() => _HeartDiseaseTestPageState();
}

class _HeartDiseaseTestPageState extends State<HeartDiseasesTestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for numeric inputs
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cigsController = TextEditingController();
  final TextEditingController totCholController = TextEditingController();
  final TextEditingController sysBPController = TextEditingController();
  final TextEditingController diaBPController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  // Gender dropdown (Male = 1, Female = 0)
  String? _gender;
  // Boolean switches for binary values
  bool isSmoker = false;
  bool bpmeds = false;
  bool hasDiabetes = false;

  String result = '';
  double probabilityValue = 0.0;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _resultAnimation;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _resultAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isModelLoaded) _interpreter.close();
    ageController.dispose();
    cigsController.dispose();
    totCholController.dispose();
    sysBPController.dispose();
    diaBPController.dispose();
    bmiController.dispose();
    heartRateController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      // Update the asset path as needed.
      _interpreter = await Interpreter.fromAsset(
        'assets/assets/Heart.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      final inputTensors = _interpreter.getInputTensors();
      // Expecting input shape [1, 12]
      if (inputTensors.isEmpty || inputTensors[0].shape[1] != 12) {
        throw Exception('Invalid input shape. Expected [1, 12]');
      }
      setState(() => _isModelLoaded = true);
      print('Heart disease model loaded successfully!');
    } catch (e) {
      setState(() {
        result = 'Model Error: ${e.toString()}';
        _isModelLoaded = false;
      });
      print('Model loading error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar(),
      body: buildBody(),
    );
  }

  AppBar _buildGradientAppBar() {
    return AppBar(
      title: const Text('Heart Disease Risk Assessment',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
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
    );
  }

  Widget buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildInputSection(),
                const SizedBox(height: 30),
                if (!_isModelLoaded) _buildModelError(),
                _buildResultDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.favorite, size: 70, color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          'Heart Disease Risk Assessment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D3A),
                letterSpacing: 1.2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Provide accurate health information for reliable results',
          style: TextStyle(
              fontSize: 16, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGenderDropdown(),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: ageController,
            label: 'Age',
            icon: Icons.cake,
            validatorMin: 0,
            validatorMax: 120,
          ),
          const SizedBox(height: 20),
          _buildSwitchInput('Current Smoker', isSmoker, (bool value) {
            setState(() {
              isSmoker = value;
            });
          }),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: cigsController,
            label: 'Cigarettes Per Day',
            icon: Icons.smoking_rooms,
            validatorMin: 0,
            validatorMax: 100,
          ),
          const SizedBox(height: 20),
          _buildSwitchInput('BP Medication', bpmeds, (bool value) {
            setState(() {
              bpmeds = value;
            });
          }),
          const SizedBox(height: 20),
          _buildSwitchInput('Diabetes', hasDiabetes, (bool value) {
            setState(() {
              hasDiabetes = value;
            });
          }),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: totCholController,
            label: 'Total Cholesterol (mg/dL)',
            icon: Icons.water_drop,
            validatorMin: 100,
            validatorMax: 500,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: sysBPController,
            label: 'Systolic BP (mm Hg)',
            icon: Icons.monitor_heart,
            validatorMin: 80,
            validatorMax: 250,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: diaBPController,
            label: 'Diastolic BP (mm Hg)',
            icon: Icons.monitor_heart,
            validatorMin: 40,
            validatorMax: 150,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: bmiController,
            label: 'BMI',
            icon: Icons.fitness_center,
            validatorMin: 10,
            validatorMax: 60,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: heartRateController,
            label: 'Heart Rate (bpm)',
            icon: Icons.speed,
            validatorMin: 30,
            validatorMax: 200,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: glucoseController,
            label: 'Glucose (mg/dL)',
            icon: Icons.opacity,
            validatorMin: 50,
            validatorMax: 500,
          ),
          const SizedBox(height: 30),
          _buildPredictButton(),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon:
            const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
      ],
      validator: (value) => value == null ? 'Please select gender' : null,
      onChanged: (value) => setState(() {
        _gender = value;
      }),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double validatorMin,
    required double validatorMax,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a value';
        final numValue = double.tryParse(value);
        if (numValue == null) return 'Invalid number';
        if (numValue < validatorMin || numValue > validatorMax)
          return 'Value must be between $validatorMin and $validatorMax';
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
    );
  }

  Widget _buildSwitchInput(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      inactiveTrackColor: Colors.grey.shade300,
      onChanged: onChanged,
    );
  }

  Widget _buildPredictButton() {
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        backgroundColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white))
          : const Text('Check Risk',
              style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildResultDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _isModelLoaded && result.isNotEmpty
          ? Container(
              key: ValueKey<String>(result),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _getResultColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _getResultColor(),
                    width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    result.contains('Positive')
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle,
                    color: _getResultColor(),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor()),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: probabilityValue,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getResultColor()),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Probability: ${(probabilityValue * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Color _getResultColor() {
    if (result.toLowerCase().contains('positive')) {
      return Colors.red;
    } else if (result.toLowerCase().contains('negative')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildModelError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          result,
          style: const TextStyle(
              fontSize: 24,
              color: Colors.red,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handlePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      result = '';
      _animationController.reset();
    });

    try {
      // Collect the 12 inputs in the required order:
      // [gender, age, currentSmoker, cigsPerDay, BPMeds, diabetes, totChol, sysBP, diaBP, BMI, heartRate, glucose]
      final rawInputs = [
        _gender == 'Male' ? 1.0 : 0.0,
        double.parse(ageController.text),
        isSmoker ? 1.0 : 0.0,
        double.parse(cigsController.text),
        bpmeds ? 1.0 : 0.0,
        hasDiabetes ? 1.0 : 0.0,
        double.parse(totCholController.text),
        double.parse(sysBPController.text),
        double.parse(diaBPController.text),
        double.parse(bmiController.text),
        double.parse(heartRateController.text),
        double.parse(glucoseController.text),
      ];
      final input = [rawInputs];
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);

      final probability = output[0][0];
      final probabilityPercentage = (probability * 100).toStringAsFixed(2);

      setState(() {
        probabilityValue = probability;
        result = probability >= 0.5
            ? 'Positive ($probabilityPercentage%)'
            : 'Negative ($probabilityPercentage%)';
      });

      _animationController.forward();
    } catch (e) {
      setState(() => result = 'Prediction failed. Check inputs');
      print("Prediction error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
