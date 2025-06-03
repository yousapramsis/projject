import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:project_grad/l10n/app_localizations.dart';

import 'hypertention_result_page.dart';

class HypertensionTestPage extends StatefulWidget {
  const HypertensionTestPage({Key? key}) : super(key: key);

  @override
  _HypertensionTestPageState createState() => _HypertensionTestPageState();
}

class _HypertensionTestPageState extends State<HypertensionTestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController cholController = TextEditingController();
  final TextEditingController sysBPController = TextEditingController();
  final TextEditingController diaBPController = TextEditingController();

  String? _gender;
  String? _smoking;
  bool hasDiabetes = false;

  String result = '';
  double probabilityValue = 0.0;
  bool _isHypertensive = false;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;

  final String _modelPath = 'assets/assets/hypertension_model.tflite';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeModel();
    });
  }

  @override
  void dispose() {
    if (_isModelLoaded && _interpreter != null) {
      _interpreter.close();
    }
    ageController.dispose();
    bmiController.dispose();
    cholController.dispose();
    sysBPController.dispose();
    diaBPController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      final interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      setState(() {
        _interpreter = interpreter;
        _isModelLoaded = true;
      });
    } catch (e) {
      setState(() {
        result = AppLocalizations.of(context)!.model_error(e.toString());
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
        appBar: _buildGradientAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  AppBar _buildGradientAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.hypertension_risk_assess),
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

  Widget buildBody(BuildContext context) {
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
                _buildHeader(context),
                const SizedBox(height: 30),
                _buildInputSection(context),
                const SizedBox(height: 30),
                if (!_isModelLoaded &&
                    result.isNotEmpty &&
                    result.startsWith('Model Load Error')) ...[
                  _buildModelError(context),
                  const SizedBox(height: 20),
                ],
                _buildResultDisplay(context),
                if (_isHypertensive) ...[
                  const SizedBox(height: 25),
                  _buildContinueButton(context),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.monitor_heart, size: 70, color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.hypertension_risk_assess,
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
          AppLocalizations.of(context)!.enter_metrics,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context) {
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
          _buildDropdown(
            context: context,
            label: AppLocalizations.of(context)!.gender,
            value: _gender,
            items: [
              AppLocalizations.of(context)!.gender_male,
              AppLocalizations.of(context)!.gender_female,
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            context: context,
            controller: ageController,
            label: AppLocalizations.of(context)!.age,
            icon: Icons.cake,
            validatorMin: 0,
            validatorMax: 120,
            normalRange: AppLocalizations.of(context)!.age_range_info,
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            context: context,
            label: AppLocalizations.of(context)!.smoking_status,
            value: _smoking,
            items: [
              AppLocalizations.of(context)!.smoking_never,
              AppLocalizations.of(context)!.smoking_former,
              AppLocalizations.of(context)!.smoking_current,
            ],
            onChanged: (v) => setState(() => _smoking = v),
            normalRange: AppLocalizations.of(context)!.cigs_per_day_range_info,
          ),
          const SizedBox(height: 20),
          _buildSwitchInput(
            AppLocalizations.of(context)!.diabetes,
            hasDiabetes,
            (bool val) => setState(() => hasDiabetes = val),
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            context: context,
            controller: bmiController,
            label: AppLocalizations.of(context)!.bmi,
            icon: Icons.fitness_center,
            validatorMin: 10,
            validatorMax: 60,
            normalRange: AppLocalizations.of(context)!.bmi_range_info,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            context: context,
            controller: cholController,
            label: AppLocalizations.of(context)!.total_cholesterol,
            icon: Icons.water_drop,
            validatorMin: 100,
            validatorMax: 500,
            normalRange:
                AppLocalizations.of(context)!.total_cholesterol_range_info,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            context: context,
            controller: sysBPController,
            label: AppLocalizations.of(context)!.systolic_bp,
            icon: Icons.monitor_heart,
            validatorMin: 80,
            validatorMax: 250,
            normalRange: AppLocalizations.of(context)!.systolic_bp_range_info,
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            context: context,
            controller: diaBPController,
            label: AppLocalizations.of(context)!.diastolic_bp,
            icon: Icons.monitor_heart,
            validatorMin: 40,
            validatorMax: 150,
            normalRange: AppLocalizations.of(context)!.diastolic_bp_range_info,
          ),
          const SizedBox(height: 30),
          _buildPredictButton(context),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String normalRange = '',
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
        suffixIcon: normalRange.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.normal_range),
                      content: Text(
                          '${AppLocalizations.of(context)!.normal_range_for} "$label": $normalRange'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(AppLocalizations.of(context)!.ok),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
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
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      validator: (v) => v == null
          ? '${AppLocalizations.of(context)!.select_option} $label'
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildNumberInput({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double validatorMin,
    required double validatorMax,
    required String normalRange,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.grey),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.normal_range),
                content: Text(
                    '${AppLocalizations.of(context)!.normal_range_for} "$label": $normalRange'),
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
        if (value == null || value.isEmpty)
          return '${AppLocalizations.of(context)!.required_field} $label';
        final numValue = double.tryParse(value);
        if (numValue == null)
          return AppLocalizations.of(context)!.invalid_number;
        if (numValue < validatorMin || numValue > validatorMax) {
          return '${AppLocalizations.of(context)!.must_be_between} ${validatorMin.toStringAsFixed(0)} ${AppLocalizations.of(context)!.and_text} ${validatorMax.toStringAsFixed(0)}';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PositiveResultPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 35),
        backgroundColor: Colors.orangeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        shadowColor: Colors.orangeAccent.withOpacity(0.4),
      ),
      child: Text(
        AppLocalizations.of(context)!.continue_advice,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: Colors.white),
      ),
    );
  }

  Widget _buildSwitchInput(
      String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }

  Widget _buildPredictButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing
          ? () => _handlePrediction(context)
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        backgroundColor: const Color(0xFF6C63FF),
        shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white),
            )
          : Text(AppLocalizations.of(context)!.check_risk,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
    );
  }

  Widget _buildResultDisplay(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child));
      },
      child: result.isNotEmpty && !result.startsWith('Model Load Error')
          ? Container(
              key: ValueKey(result),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getResultColor(_isHypertensive).withOpacity(0.1),
                border: Border.all(
                    color: _getResultColor(_isHypertensive), width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(
                    _isHypertensive
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle,
                    color: _getResultColor(_isHypertensive),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getResultColor(_isHypertensive),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: probabilityValue,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getResultColor(_isHypertensive)),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppLocalizations.of(context)!.probability}: ${(probabilityValue * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Color _getResultColor(bool isHypertensive) {
    if (isHypertensive) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  Future<void> _handlePrediction(BuildContext context) async {
    setState(() {
      _isProcessing = true;
      result = '';
      probabilityValue = 0.0;
      _isHypertensive = false;
    });

    await Future.delayed(const Duration(milliseconds: 50));

    if (!_formKey.currentState!.validate()) {
      setState(() => _isProcessing = false);
      return;
    }

    if (!_isModelLoaded || _interpreter == null) {
      setState(() {
        result = AppLocalizations.of(context)!
            .model_error(AppLocalizations.of(context)!.failed_to_load_model);
        _isProcessing = false;
      });
      return;
    }

    try {
      final rawInputs = [
        double.parse(ageController.text),
        _gender == AppLocalizations.of(context)!.gender_male ? 1.0 : 0.0,
        _getSmokingValue(_smoking, context),
        double.parse(bmiController.text),
        double.parse(cholController.text),
        double.parse(sysBPController.text),
        double.parse(diaBPController.text),
        hasDiabetes ? 1.0 : 0.0
      ];

      final scaledInputs = _scaleInput(rawInputs);
      final input = [scaledInputs];
      final output = List.filled(1, 0.0).reshape([1, 1]);

      _interpreter.run(input, output);
      final prediction = output[0][0];

      final isHypertensiveResult = prediction >= 0.5;
      final probabilityPercentage = (prediction * 100).toStringAsFixed(2);
      final resultText = isHypertensiveResult
          ? AppLocalizations.of(context)!.positive
          : AppLocalizations.of(context)!.negative;

      setState(() {
        probabilityValue = prediction;
        result = '$resultText ($probabilityPercentage%)';
        _isHypertensive = isHypertensiveResult;
      });
    } catch (e) {
      setState(() {
        result = AppLocalizations.of(context)!.model_error(e.toString());
        _isHypertensive = false;
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  double _getSmokingValue(String? smokingStatus, BuildContext context) {
    switch (smokingStatus) {
      case 'لم يدخن': // Never
        return 0.0;
      case 'مدخن سابق': // Formerly
        return 0.5;
      case 'مدخن حالياً': // Smokes
        return 1.0;
      default:
        return 0.0;
    }
  }

  List<double> _scaleInput(List<double> rawInputs) {
    final minValues = [0.0, 0.0, 0.0, 10.0, 100.0, 80.0, 40.0, 0.0];
    final maxValues = [120.0, 1.0, 1.0, 60.0, 500.0, 250.0, 150.0, 1.0];

    if (rawInputs.length != minValues.length ||
        rawInputs.length != maxValues.length) {
      return rawInputs;
    }

    List<double> scaled = [];
    for (int i = 0; i < rawInputs.length; i++) {
      final min = minValues[i];
      final max = maxValues[i];
      if (max == min) {
        scaled.add(rawInputs[i]);
      } else {
        scaled.add((rawInputs[i] - min) / (max - min));
      }
    }
    return scaled;
  }

  Widget _buildModelError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          result.isNotEmpty
              ? result
              : AppLocalizations.of(context)!.failed_to_load_model,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
