import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:collection/collection.dart'; // Import for deepEquals
import 'positive_result_page.dart'; // <-- Import the new page

class DiabetesTestPage extends StatefulWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);

  @override
  _DiabetesTestPageState createState() => _DiabetesTestPageState();
}

class _DiabetesTestPageState extends State<DiabetesTestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController hba1cController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();
  String? _gender;
  bool hasHypertension = false;
  bool hasHeartDisease = false;
  String result = '';
  double probabilityValue = 0.0;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _resultAnimation;
  String? _smokingHistory;

  // ... (Keep your existing variables like _featureNames, _means, _stds) ...

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
    // ... (Keep your existing dispose method) ...
     _animationController.dispose();
    if (_isModelLoaded) _interpreter.close();
    ageController.dispose();
    bmiController.dispose();
    hba1cController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
     // ... (Keep your existing _initializeModel method) ...
     try {
      _interpreter = await Interpreter.fromAsset(
        'assets/assets/diabetes_model_fixed.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      final inputTensors = _interpreter.getInputTensors();
      final outputTensors = _interpreter.getOutputTensors();
      if (inputTensors.length != 1 || inputTensors[0].shape[1] != 8) {
        throw Exception('Invalid input shape. Expected [1, 8]');
      }
      setState(() => _isModelLoaded = true);
      print('Model loaded and tested successfully!');
    } catch (e) {
      setState(() {
        result = 'Model Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isModelLoaded = false;
      });
      print('Model loading error: ${e.toString()}');
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
    // ... (Keep your existing _buildGradientAppBar method) ...
     return AppBar(
      title: const Text('Diabetes Risk Assessment',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.1)),
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
    // --- Modified buildBody ---
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
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
                _buildInputSection(), // Contains the predict button now
                const SizedBox(height: 30),
                if (!_isModelLoaded) _buildModelError(),
                _buildResultDisplay(), // Displays the result text/probability

                // --- NEW: Conditionally show the Continue button ---
                if (result.isNotEmpty && result.toLowerCase().contains('positive')) ...[
                  const SizedBox(height: 25),
                  _buildContinueButton(),
                ],
                // --- End of NEW section ---

                const SizedBox(height: 20), // Add some padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
    // --- End of modified buildBody ---
  }

  // ... (Keep _buildHeader, _buildInputSection, _buildSmokingHistoryDropdown, etc.) ...
  // Make sure _buildPredictButton is called inside _buildInputSection as before

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
            _buildSmokingHistoryDropdown(), // Smoking history dropdown
            const SizedBox(height: 20),
            _buildNumberInputs(),
            const SizedBox(height: 20),
            _buildHealthConditions(),
            const SizedBox(height: 30),
            _buildPredictButton(), // Predict button remains here
          ],
        ),
      );
    }


  Widget _buildResultDisplay() {
    // ... (Keep your existing _buildResultDisplay method) ...
    // No changes needed here, it just displays the text result
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
              key: ValueKey(result), // Add key for smoother animation
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _getResultColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getResultColor(), width: 2),
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
                    result, // Show the full result (e.g., "Positive (75.23%)")
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor()),
                     textAlign: TextAlign.center, // Center align text
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
          : const SizedBox.shrink(), // Use SizedBox.shrink when no result
    );
  }

  // --- NEW: Method to build the Continue button ---
  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the PositiveResultPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PositiveResultPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 35),
        backgroundColor: Colors.orangeAccent, // A different color to stand out
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        shadowColor: Colors.orangeAccent.withOpacity(0.4),
      ),
      child: const Text(
        'Continue for Advice',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: Colors.white
        ),
      ),
    );
  }
  // --- End of NEW method ---


  // ... (Keep _getResultColor, _buildModelError, _buildGenderDropdown, etc.) ...

  Color _getResultColor() {
    if (result.toLowerCase().contains('positive')) {
      return Colors.red;
    } else if (result.toLowerCase().contains('negative')) {
      return Colors.green;
    } else {
      return Colors.grey; // For errors or initial state
    }
  }

  // ... (Keep _buildNumberInputs, _buildNumberInput, _buildHealthConditions, etc.) ...


  Widget _buildPredictButton() {
    // ... (Keep your existing _buildPredictButton method) ...
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        backgroundColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  fontWeight: FontWeight.w600,
                  color: Colors.white)), // Ensure text color is white
    );
  }

  // ... (Keep _validateRange, _standardizeInputs, _handlePrediction) ...
  // Make sure _handlePrediction correctly sets the `result` state variable

  Future<void> _handlePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      result = ''; // Clear previous result
      _animationController.reset();
    });

    await Future.delayed(const Duration(milliseconds: 50)); // Small delay for UI update

    try {
      final rawInputs = [
        double.parse(ageController.text),
        double.parse(bmiController.text),
        hasHypertension ? 1.0 : 0.0,
        hasHeartDisease ? 1.0 : 0.0,
        double.parse(hba1cController.text),
        double.parse(glucoseController.text),
        _gender == 'Male' ? 1.0 : 0.0,
        _smokingHistory == 'Current' ? 1.0 : 0.0,
      ];

      final standardizedInput = _standardizeInputs(rawInputs);
      final input = [standardizedInput];
      final output = [List<double>.filled(1, 0.0)];

      _interpreter.run(input, output);

      final probability = output[0][0];
      final probabilityPercentage = (probability * 100).toStringAsFixed(2);
      print("Model Probability: $probability ($probabilityPercentage%)");

      // --- IMPORTANT: Update state with result and probability ---
      setState(() {
        probabilityValue = probability;
        // Set the result string including the percentage
        result = probability >= 0.4 // Your threshold
            ? 'Positive ($probabilityPercentage%)'
            : 'Negative ($probabilityPercentage%)';
      });
      // --- End of state update ---


      _animationController.forward();
    } catch (e) {
      setState(() => result = 'Prediction failed. Check inputs');
      print("Prediction error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Method to get color for result text (already exists, ensure it's used)
  // Color _getResultColorForResult() { // You named it _getResultColor() - which is fine
  //   return result.toLowerCase().contains('positive') ? Colors.red : Colors.green;
  // }

  // ... rest of your class ...
  List<double> _standardizeInputs(List<double> rawInputs) {
      Map<String, double> inputMap = {
        'age': rawInputs[0],
        'bmi': rawInputs[1],
        'hypertension': rawInputs[2],
        'heart_disease': rawInputs[3],
        'HbA1c_level': rawInputs[4],
        'blood_glucose_level': rawInputs[5],
        'gender_Male': rawInputs[6],
        'smoking_history_current': rawInputs[7],
      };
      final List<double> standardizedInputs = [];
      for (final feature in _featureNames) {
        final rawValue = inputMap[feature]!;
        final mean = _means[feature]!;
        final std = _stds[feature]!;
        // Add check for std deviation being zero to avoid division by zero
        standardizedInputs.add(std == 0 ? 0.0 : (rawValue - mean) / std);
      }
      print('Standardized inputs: $standardizedInputs');
      return standardizedInputs;
    }

    Widget _buildHeader() {
        return Column(
          children: [
            const Icon(Icons.health_and_safety, size: 70, color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            Text(
              'Diabetes Risk Assessment',
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
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }

       Widget _buildSmokingHistoryDropdown() {
        return DropdownButtonFormField<String>(
          value: _smokingHistory,
          decoration: InputDecoration(
            labelText: 'Smoking History',
            labelStyle: const TextStyle(color: Colors.black87),
            prefixIcon: const Icon(Icons.smoking_rooms, color: Color(0xFF6C63FF)),
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
            DropdownMenuItem(value: 'Never', child: Text('Never')),
            DropdownMenuItem(value: 'Current', child: Text('Current')),
            DropdownMenuItem(value: 'Former', child: Text('Former')),
            DropdownMenuItem(value: 'No Info', child: Text('No Info')),
          ],
          validator: (value) =>
              value == null ? 'Please select smoking history' : null,
          onChanged: (value) => setState(() => _smokingHistory = value),
        );
      }

       Widget _buildModelError() {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              result, // Display the error message from the 'result' variable
              style: const TextStyle(
                fontSize: 18, // Adjusted size slightly
                color: Colors.redAccent, // Use a distinct error color
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

       Widget _buildGenderDropdown() {
        return DropdownButtonFormField<String>(
          value: _gender,
          decoration: InputDecoration(
            labelText: 'Gender',
            labelStyle: const TextStyle(color: Colors.black87),
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
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
          onChanged: (value) => setState(() => _gender = value),
        );
      }

       Widget _buildNumberInputs() {
        return Column(
          children: [
            _buildNumberInput(
              controller: ageController,
              label: 'Age',
              icon: Icons.cake,
              validator: (v) => _validateRange(v, 0, 100), // Example range
            ),
            const SizedBox(height: 15),
            _buildNumberInput(
              controller: bmiController,
              label: 'BMI',
              icon: Icons.monitor_weight,
              validator: (v) => _validateRange(v, 10, 60), // Example range
            ),
            const SizedBox(height: 15),
            _buildNumberInput(
              controller: hba1cController,
              label: 'HbA1c (%)',
              icon: Icons.bloodtype,
              validator: (v) => _validateRange(v, 3, 10), // Example range
            ),
            const SizedBox(height: 15),
            _buildNumberInput(
              controller: glucoseController,
              label: 'Glucose (mg/dL)',
              icon: Icons.favorite,
              validator: (v) => _validateRange(v, 50, 400), // Example range
            ),
          ],
        );
      }

       Widget _buildNumberInput({
        required TextEditingController controller,
        required String label,
        required IconData icon,
        String? Function(String?)? validator,
      }) {
        return TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true), // Allow decimals
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
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
          validator: validator,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
          ],
        );
      }

      Widget _buildHealthConditions() {
        return Column(
          children: [
            _buildConditionSwitch('Hypertension', hasHypertension),
            _buildConditionSwitch('Heart Disease', hasHeartDisease),
          ],
        );
      }

      Widget _buildConditionSwitch(String label, bool value) {
        return SwitchListTile(
          title: Text(label, style: const TextStyle(color: Colors.black87)), // Ensure text color
          value: value,
          activeColor: const Color(0xFF6C63FF),
          inactiveTrackColor: Colors.grey.shade300,
          contentPadding: EdgeInsets.zero,
          onChanged: (bool? newValue) {
            setState(() {
              if (label == 'Hypertension') {
                hasHypertension = newValue ?? false; // Use null check
              } else {
                hasHeartDisease = newValue ?? false; // Use null check
              }
            });
          },
        );
      }

        String? _validateRange(String? value, double min, double max) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return 'Invalid number';
          }
          if (numValue < min || numValue > max) {
            return 'Value must be between $min and $max';
          }
          return null;
        }


        // Keep your featureNames, means, stds variables
        final List<String> _featureNames = [
          "age", "bmi", "hypertension", "heart_disease", "HbA1c_level",
          "blood_glucose_level", "gender_Male", "smoking_history_current"
        ];

        final Map<String, double> _means = {
          'age': 41.886460, 'bmi': 27.320767, 'hypertension': 0.074850,
          'heart_disease': 0.039420, 'HbA1c_level': 5.527770,
          'blood_glucose_level': 138.058060, 'gender_Male': 0.585790,
          'smoking_history_current': 0.091660,
        };

        final Map<String, double> _stds = {
          'age': 22.516840, 'bmi': 6.698994, 'hypertension': 0.263150,
          'heart_disease': 0.194593, 'HbA1c_level': 1.070672,
          'blood_glucose_level': 40.709130, 'gender_Male': 0.492592,
          'smoking_history_current': 0.288553,
        };

} // End of _DiabetesTestPageState class