import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_grad/l10n/app_localizations.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../Hypertention/hypertention_result_page.dart' show PositiveResultPage;

class HeartDiseasesTestPage extends StatefulWidget {
  const HeartDiseasesTestPage({Key? key}) : super(key: key);

  @override
  _HeartDiseaseTestPageState createState() => _HeartDiseaseTestPageState();
}

class _HeartDiseaseTestPageState extends State<HeartDiseasesTestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cigsController = TextEditingController();
  final TextEditingController totCholController = TextEditingController();
  final TextEditingController sysBPController = TextEditingController();
  final TextEditingController diaBPController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  String? _gender;
  bool isSmoker = false;
  bool bpmeds = false;
  bool hasDiabetes = false;
  String result = '';
  double probabilityValue = 0.0;
  bool _isPositiveResult = false;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _resultAnimation;
  final String _modelPath = 'assets/assets/Heart.tflite';

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
      final interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      final inputTensors = interpreter.getInputTensors();
      if (inputTensors.isEmpty || inputTensors[0].shape[1] != 12) {
        throw Exception('Invalid input shape');
      }
      _interpreter = interpreter;
      setState(() => _isModelLoaded = true);
    } catch (e) {
      setState(() {
        // Fix: Using string instead of function for error message
        result = 'Model Load Error: ${e.toString()}';
        _isModelLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocalizations.of(context)!.isRtl == "true"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: _buildGradientAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildGradientAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.heart_disease_risk_assess),
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
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildBody() {
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
                if (!_isModelLoaded && result.isNotEmpty) _buildModelError(),
                _buildResultDisplay(),
                if (_isPositiveResult) ...[
                  const SizedBox(height: 25),
                  _buildContinueButton(),
                ],
                const SizedBox(height: 20),
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
          AppLocalizations.of(context)!.heart_disease_risk_assess,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D3A),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.provide_health_info,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
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
          _buildNumberInputs(),
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
        labelText: AppLocalizations.of(context)!.gender,
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
      ),
      items: [
        DropdownMenuItem(
          value: 'Male',
          child: Text(AppLocalizations.of(context)!.gender_male),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text(AppLocalizations.of(context)!.gender_female),
        ),
      ],
      validator: (value) =>
          value == null ? AppLocalizations.of(context)!.required_field : null,
      onChanged: (value) => setState(() => _gender = value),
    );
  }

  Widget _buildNumberInputs() {
    return Column(
      children: [
        _buildNumberInput(
          controller: ageController,
          label: AppLocalizations.of(context)!.age,
          icon: Icons.cake,
          validatorMin: 0,
          validatorMax: 120,
        ),
        _buildSwitchInput(AppLocalizations.of(context)!.current_smoker,
            isSmoker, (v) => setState(() => isSmoker = v)),
        _buildNumberInput(
          controller: cigsController,
          label: AppLocalizations.of(context)!.cigarettes_per_day,
          icon: Icons.smoking_rooms,
          validatorMin: 0,
          validatorMax: 20,
        ),
        _buildSwitchInput(AppLocalizations.of(context)!.bp_medication, bpmeds,
            (v) => setState(() => bpmeds = v)),
        _buildSwitchInput(AppLocalizations.of(context)!.diabetes, hasDiabetes,
            (v) => setState(() => hasDiabetes = v)),
        _buildNumberInput(
          controller: totCholController,
          label: AppLocalizations.of(context)!.total_cholesterol,
          icon: Icons.water_drop,
          validatorMin: 100,
          validatorMax: 500,
        ),
        _buildNumberInput(
          controller: sysBPController,
          label: AppLocalizations.of(context)!.systolic_bp,
          icon: Icons.monitor_heart,
          validatorMin: 80,
          validatorMax: 250,
        ),
        _buildNumberInput(
          controller: diaBPController,
          label: AppLocalizations.of(context)!.diastolic_bp,
          icon: Icons.monitor_heart,
          validatorMin: 40,
          validatorMax: 150,
        ),
        _buildNumberInput(
          controller: bmiController,
          label: AppLocalizations.of(context)!.bmi,
          icon: Icons.fitness_center,
          validatorMin: 10,
          validatorMax: 60,
        ),
        _buildNumberInput(
          controller: heartRateController,
          label: AppLocalizations.of(context)!.heart_rate,
          icon: Icons.speed,
          validatorMin: 30,
          validatorMax: 200,
        ),
        _buildNumberInput(
          controller: glucoseController,
          label: AppLocalizations.of(context)!.glucose,
          icon: Icons.opacity,
          validatorMin: 50,
          validatorMax: 500,
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double validatorMin,
    required double validatorMax,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.normal_range),
                  content: Text(
                    '${AppLocalizations.of(context)!.normal_range_for} "$label":\n'
                    '${validatorMin.toStringAsFixed(0)} - ${validatorMax.toStringAsFixed(0)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ],
                ),
              );
            },
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FF),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.required_field;
          }
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return AppLocalizations.of(context)!.invalid_number;
          }
          if (numValue < validatorMin || numValue > validatorMax) {
            return '${AppLocalizations.of(context)!.must_be_between} '
                '${validatorMin.toStringAsFixed(0)} '
                '${AppLocalizations.of(context)!.and_text} '
                '${validatorMax.toStringAsFixed(0)}';
          }
          return null;
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
        ],
      ),
    );
  }

  Widget _buildSwitchInput(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      onChanged: onChanged,
    );
  }

  Widget _buildPredictButton() {
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        backgroundColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: _isProcessing
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              AppLocalizations.of(context)!.check_risk,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
    );
  }

  Widget _buildResultDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: result.isNotEmpty && !result.startsWith('Model Load Error')
          ? Container(
              key: ValueKey<String>(result),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _getResultColor(_isPositiveResult).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _getResultColor(_isPositiveResult), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _isPositiveResult
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle,
                    color: _getResultColor(_isPositiveResult),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(_isPositiveResult)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: probabilityValue,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getResultColor(_isPositiveResult)),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppLocalizations.of(context)!.probability}: '
                    '${(probabilityValue * 100).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PositiveResultPage()),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 35),
        backgroundColor: Colors.orangeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        AppLocalizations.of(context)!.continue_advice,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Color _getResultColor(bool isPositive) {
    return isPositive ? Colors.red : Colors.green;
  }

  Widget _buildModelError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          result,
          style: const TextStyle(
              fontSize: 18,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handlePrediction() async {
    setState(() {
      _isProcessing = true;
      result = '';
      probabilityValue = 0.0;
      _isPositiveResult = false;
      _animationController.reset();
    });

    await Future.delayed(const Duration(milliseconds: 50));

    if (!_formKey.currentState!.validate()) {
      setState(() => _isProcessing = false);
      return;
    }

    if (!_isModelLoaded) {
      setState(() {
        // Fix: Using string concatenation instead of replaceAll
        result = 'Model Load Error: Model not loaded';
        _isProcessing = false;
      });
      return;
    }

    try {
      final input = [
        [
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
        ]
      ];

      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);

      final probability = output[0][0];
      final isPositive = probability >= 0.5;
      final percentage = (probability * 100).toStringAsFixed(2);

      setState(() {
        probabilityValue = probability;
        result = isPositive
            ? '${AppLocalizations.of(context)!.positive} ($percentage%)'
            : '${AppLocalizations.of(context)!.negative} ($percentage%)';
        _isPositiveResult = isPositive;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        result =
            '${AppLocalizations.of(context)!.error_occurred}: ${e.toString()}';
        _isPositiveResult = false;
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
