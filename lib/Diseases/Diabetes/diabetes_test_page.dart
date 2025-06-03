import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_grad/l10n/app_localizations.dart' show AppLocalizations;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'positive_result_page.dart';

class DiabetesTestPage extends StatefulWidget {
  const DiabetesTestPage({super.key});
  @override
  _DiabetesTestPageState createState() => _DiabetesTestPageState();
}

class _DiabetesTestPageState extends State<DiabetesTestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Existing inputs
  final ageController = TextEditingController();
  final bmiController = TextEditingController();
  final hba1cController = TextEditingController();
  final glucoseController = TextEditingController();

  // New lipid inputs
  final cholesterolController = TextEditingController();
  final ldlController = TextEditingController();
  final triglyceridesController = TextEditingController();
  final hdlController = TextEditingController();

  String? _gender;
  String? _smokingHistory;
  bool hasHypertension = false;
  bool hasHeartDisease = false;

  String result = '';
  double probabilityValue = 0.0;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _resultAnimation;

  // Language toggle for demo purposes
  String _currentLang = 'en'; // Default to English

  // Feature-scaling metadata (unchanged)
  final _featureNames = [
    'age',
    'bmi',
    'hypertension',
    'heart_disease',
    'HbA1c_level',
    'blood_glucose_level',
    'gender_Male',
    'smoking_history_current'
  ];
  final _means = {
    'age': 41.88646,
    'bmi': 27.320767,
    'hypertension': 0.07485,
    'heart_disease': 0.03942,
    'HbA1c_level': 5.52777,
    'blood_glucose_level': 138.05806,
    'gender_Male': 0.58579,
    'smoking_history_current': 0.09166
  };
  final _stds = {
    'age': 22.51684,
    'bmi': 6.698994,
    'hypertension': 0.26315,
    'heart_disease': 0.194593,
    'HbA1c_level': 1.070672,
    'blood_glucose_level': 40.70913,
    'gender_Male': 0.492592,
    'smoking_history_current': 0.288553
  };

  @override
  void initState() {
    super.initState();
    _loadModel();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _resultAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    ageController.dispose();
    bmiController.dispose();
    hba1cController.dispose();
    glucoseController.dispose();
    cholesterolController.dispose();
    ldlController.dispose();
    triglyceridesController.dispose();
    hdlController.dispose();
    if (_isModelLoaded) _interpreter.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/assets/diabetes_model_fixed.tflite',
          options: InterpreterOptions()..threads = 4);
      final inputTensors = _interpreter.getInputTensors();
      if (inputTensors.length != 1 || inputTensors[0].shape[1] != 8) {
        throw Exception('Model expects [1,8] inputs');
      }
      setState(() => _isModelLoaded = true);
    } catch (e) {
      setState(() {
        result = '${AppLocalizations.of(context)!.model_error}'
            .replaceAll('{error}', e.toString());
        _isModelLoaded = false;
      });
    }
  }

  // Toggle language for demo
  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == 'en' ? 'ar' : 'en';
      // In a real app, update the app's locale here (e.g., via Provider or setState)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocalizations.of(context)!.isRtl == "true"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.diabetes_risk_assess),
          centerTitle: true,
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight))),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _toggleLanguage, // Toggle language for demo
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)])),
          child: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30),
                            _buildInputsCard(),
                            const SizedBox(height: 30),
                            if (!_isModelLoaded) _buildError(),
                            _buildResult(),
                            if (result.contains(
                                AppLocalizations.of(context)!.positive)) ...[
                              const SizedBox(height: 25),
                              _buildContinueButton(),
                            ],
                            const SizedBox(height: 20),
                          ])))),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(children: [
        const Icon(Icons.health_and_safety, size: 70, color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.diabetes_risk_assess,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.provide_health_info,
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
      ]);

  Widget _buildInputsCard() => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5)
          ],
        ),
        child: Column(children: [
          _buildDropdown(
              AppLocalizations.of(context)!.gender,
              [
                AppLocalizations.of(context)!.gender_male,
                AppLocalizations.of(context)!.gender_female
              ],
              _gender,
              (v) => setState(() => _gender = v)),
          const SizedBox(height: 20),
          _buildDropdown(
              AppLocalizations.of(context)!.smoking_history,
              [
                AppLocalizations.of(context)!.smoking_never,
                AppLocalizations.of(context)!.smoking_current,
                AppLocalizations.of(context)!.smoking_former,
                AppLocalizations.of(context)!.smoking_no_info
              ],
              _smokingHistory,
              (v) => setState(() => _smokingHistory = v)),
          const SizedBox(height: 20),
          _buildNumberInput(ageController, AppLocalizations.of(context)!.age,
              'cake', 0, 100, AppLocalizations.of(context)!.age_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(
              bmiController,
              AppLocalizations.of(context)!.bmi,
              'monitor_weight',
              10,
              60,
              AppLocalizations.of(context)!.bmi_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(
              hba1cController,
              AppLocalizations.of(context)!.hba1c,
              'bloodtype',
              3,
              10,
              AppLocalizations.of(context)!.hba1c_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(
              glucoseController,
              AppLocalizations.of(context)!.glucose,
              'favorite',
              50,
              400,
              AppLocalizations.of(context)!.glucose_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(
              cholesterolController,
              AppLocalizations.of(context)!.cholesterol,
              'water_drop',
              0,
              500,
              AppLocalizations.of(context)!.total_cholesterol_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(ldlController, AppLocalizations.of(context)!.ldl,
              'layers', 0, 300, AppLocalizations.of(context)!.ldl_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(
              triglyceridesController,
              AppLocalizations.of(context)!.triglycerides,
              'bubble_chart',
              0,
              500,
              AppLocalizations.of(context)!.triglycerides_range_info),
          const SizedBox(height: 15),
          _buildNumberInput(hdlController, AppLocalizations.of(context)!.hdl,
              'circle', 0, 200, AppLocalizations.of(context)!.hdl_range_info),
          const SizedBox(height: 20),
          _buildSwitch(AppLocalizations.of(context)!.hypertension,
              hasHypertension, (v) => setState(() => hasHypertension = v!)),
          _buildSwitch(AppLocalizations.of(context)!.heart_disease,
              hasHeartDisease, (v) => setState(() => hasHeartDisease = v!)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isModelLoaded && !_isProcessing ? _predict : null,
            child: _isProcessing
                ? const SizedBox(
                    width: 25, height: 25, child: CircularProgressIndicator())
                : Text(AppLocalizations.of(context)!.check_risk),
          ),
        ]),
      );

  Widget _buildDropdown(String label, List<String> opts, String? val,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: val,
      decoration: InputDecoration(
          labelText: label, filled: true, fillColor: const Color(0xFFF8F9FF)),
      items:
          opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      validator: (v) => v == null
          ? AppLocalizations.of(context)!
              .select_option
              .replaceAll('{label}', label)
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildNumberInput(
    TextEditingController c,
    String label,
    String iconName,
    double min,
    double max,
    String infoText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: c,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                IconData(IconsMap[iconName]!, fontFamily: 'MaterialIcons'),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
            ),
            validator: (v) => _validateRange(v, min, max),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!
                    .normal_range_for
                    .replaceAll('{label}', label)),
                content: Text(infoText),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper map for icons
  static const Map<String, int> IconsMap = {
    'cake': 0xe7fb,
    'monitor_weight': 0xeb44,
    'bloodtype': 0xec37,
    'favorite': 0xe87d,
    'water_drop': 0xec11,
    'layers': 0xe53a,
    'bubble_chart': 0xe7b7,
    'circle': 0xe83f
  };

  Widget _buildSwitch(String label, bool val, ValueChanged<bool?> onChanged) {
    return SwitchListTile(
        title: Text(label),
        value: val,
        activeColor: const Color(0xFF6C63FF),
        onChanged: onChanged);
  }

  Widget _buildError() => Center(
      child: Text(result,
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)));

  Widget _buildResult() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: result.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.1),
                  border: Border.all(color: _getColor(), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  Icon(
                      result.contains(AppLocalizations.of(context)!.positive)
                          ? Icons.warning
                          : Icons.check,
                      color: _getColor(),
                      size: 60),
                  const SizedBox(height: 20),
                  Text(result,
                      style: TextStyle(color: _getColor(), fontSize: 24)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: probabilityValue),
                  const SizedBox(height: 12),
                  Text('${AppLocalizations.of(context)!.probability}'
                          .replaceAll('{value}',
                              (probabilityValue * 100).toStringAsFixed(2)) +
                      '%'),
                ]),
              ),
      );

  Widget _buildContinueButton() => ElevatedButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PositiveResultPage())),
        child: Text(AppLocalizations.of(context)!.continue_advice),
      );

  Color _getColor() {
    if (result.contains(AppLocalizations.of(context)!.positive))
      return Colors.red;
    if (result.contains(AppLocalizations.of(context)!.negative))
      return Colors.green;
    return Colors.grey;
  }

  String? _validateRange(String? v, double min, double max) {
    if (v == null || v.isEmpty)
      return AppLocalizations.of(context)!.enter_value;
    final n = double.tryParse(v);
    if (n == null) return AppLocalizations.of(context)!.invalid_number;
    if (n < min || n > max)
      return AppLocalizations.of(context)!
          .must_be_between
          .replaceAll('{min}', min.toString())
          .replaceAll('{max}', max.toString());
    return null;
  }

  List<double> _standardizeInputs(List<double> raw) {
    final map = Map.fromIterables(_featureNames, raw);
    return _featureNames.map((f) {
      final std = _stds[f]!;
      return std == 0 ? 0.0 : (map[f]! - _means[f]!) / std;
    }).toList();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() =>
        {_isProcessing = true, result = '', _animationController.reset()});
    await Future.delayed(const Duration(milliseconds: 50));

    // Lipid cutoffs
    final chol = double.tryParse(cholesterolController.text) ?? 0;
    final ldl = double.tryParse(ldlController.text) ?? 0;
    final tri = double.tryParse(triglyceridesController.text) ?? 0;
    final hdl = double.tryParse(hdlController.text) ?? double.infinity;
    if (chol > 200 || ldl > 100 || tri > 150 || hdl < 40) {
      setState(() {
        probabilityValue = 1.0;
        result = '${AppLocalizations.of(context)!.positive} (100.00%)';
        _isProcessing = false;
      });
      _animationController.forward();
      return;
    }

    final rawInputs = [
      double.parse(ageController.text),
      double.parse(bmiController.text),
      hasHypertension ? 1.0 : 0.0,
      hasHeartDisease ? 1.0 : 0.0,
      double.parse(hba1cController.text),
      double.parse(glucoseController.text),
      _gender == AppLocalizations.of(context)!.gender_male ? 1.0 : 0.0,
      _smokingHistory == AppLocalizations.of(context)!.smoking_current
          ? 1.0
          : 0.0,
    ];
    final input = [_standardizeInputs(rawInputs)];
    final output = [List<double>.filled(1, 0.0)];
    _interpreter.run(input, output);
    final p = output[0][0];
    final perc = (p * 100).toStringAsFixed(2);
    setState(() {
      probabilityValue = p;
      result = p >= 0.4
          ? '${AppLocalizations.of(context)!.positive} ($perc%)'
          : '${AppLocalizations.of(context)!.negative} ($perc%)';
      _isProcessing = false;
    });
    _animationController.forward();
  }
}
