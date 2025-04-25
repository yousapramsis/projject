import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// Import the PositiveResultPage for navigation when risk is positive
import 'hypertention_result_page.dart';
// Comment out or remove this import if PositiveResultPage is the intended destination for positive results
// import 'hypertention_result_page.dart';

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

  String result = ''; // Stores the result text, now includes percentage
  double probabilityValue = 0.0; // Stores the raw probability (0.0 to 1.0)
  bool _isHypertensive = false; // <-- NEW: Flag to track positive result

  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;

  final String _modelPath = 'assets/assets/hypertension_model.tflite'; // Ensure this path is correct

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  @override
  void dispose() {
    // Dispose the interpreter only if it was successfully loaded and assigned
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
       // Basic check to see if it looks like a valid model
      if (interpreter.getInputTensor(0).shape.isEmpty || interpreter.getOutputTensor(0).shape.isEmpty) {
           throw Exception('Model seems empty or invalid.');
      }
      _interpreter = interpreter; // Assign only on success
      setState(() => _isModelLoaded = true);
      print('Hypertension model loaded successfully from $_modelPath.');
    } catch (e) {
      setState(() {
        result = 'Model Load Error: ${e.toString()}'; // Set error message to result
        _isModelLoaded = false;
      });
      print('Error loading Hypertension model from $_modelPath: $e');
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
      title: const Text('Hypertension Risk Assessment',
          style: TextStyle(color: Colors.white)),
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

                // Show model error if it failed to load
                 if (!_isModelLoaded && result.isNotEmpty && result.startsWith('Model Load Error')) ...[
                     _buildModelError(), // Use the specific error builder
                     const SizedBox(height: 20), // Add spacing
                 ],

                _buildResultDisplay(), // Displays the prediction result and probability

                // --- Conditional Continue Button ---
                // Show button ONLY if the _isHypertensive flag is true
                if (_isHypertensive) ...[ // <-- Check the boolean flag
                    const SizedBox(height:25),
                    _buildContinueButton(),
                ],
                 // --- End Conditional Button ---
                 const SizedBox(height: 20), // Padding at the bottom
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
        const Icon(Icons.monitor_heart, size: 70, color: Color(0xFF6C63FF)),
        const SizedBox(height: 20),
        Text(
          'Hypertension Risk Assessment',
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
          'Enter your health metrics for an assessment',
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
          _buildDropdown(
            label: 'Gender',
            value: _gender,
            items: ['Male', 'Female'],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 20),
          _buildNumberInput(
            controller: ageController,
            label: 'Age',
            icon: Icons.cake,
            validatorMin: 0,
            validatorMax: 120,
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Smoking Status',
            value: _smoking,
            items: ['Never', 'Formerly', 'Smokes'],
            onChanged: (v) => setState(() => _smoking = v),
          ),
          const SizedBox(height: 20),
          _buildSwitchInput(
            'Diabetes',
            hasDiabetes,
            (bool val) => setState(() => hasDiabetes = val),
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
            controller: cholController,
            label: 'Cholesterol (mg/dL)',
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
          const SizedBox(height: 30),
          _buildPredictButton(),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      validator: (v) => v == null ? 'Please select $label' : null,
      onChanged: onChanged,
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        final numValue = double.tryParse(value);
        if (numValue == null) return 'Invalid number';
        if (numValue < validatorMin || numValue > validatorMax) {
          return 'Value must be between ${validatorMin.toStringAsFixed(0)} and ${validatorMax.toStringAsFixed(0)}';
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the PositiveResultPage (same advice page as diabetes)
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

  Widget _buildSwitchInput(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }

  Widget _buildPredictButton() {
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
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
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
            )
          : const Text('Check Risk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  Widget _buildResultDisplay() {
    // AnimatedSwitcher for smoother appearance/disappearance
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
      },
      // Use a ValueKey to ensure the animation triggers when content changes
      child: result.isNotEmpty && !result.startsWith('Model Load Error') // Don't show result box for model errors
          ? Container(
               key: ValueKey(result), // Key based on the result string
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Use color based on the _isHypertensive flag
                color: _getResultColor(_isHypertensive).withOpacity(0.1),
                border: Border.all(color: _getResultColor(_isHypertensive), width: 2), // Border with color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                   Icon(
                    // Choose icon based on the _isHypertensive flag
                    _isHypertensive
                        ? Icons.warning_amber_rounded // Warning icon for positive
                        : Icons.check_circle, // Check icon for negative
                    color: _getResultColor(_isHypertensive), // Icon color matches result color
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result, // Display the result string (includes percentage)
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getResultColor(_isHypertensive), // Text color matches result color
                    ),
                    textAlign: TextAlign.center,
                  ),
                   const SizedBox(height: 12),
                   LinearProgressIndicator(
                     value: probabilityValue, // Use the raw probability value
                     backgroundColor: Colors.grey.shade300,
                     valueColor: AlwaysStoppedAnimation<Color>(_getResultColor(_isHypertensive)),
                     minHeight: 10,
                     borderRadius: BorderRadius.circular(5),
                   ),
                   const SizedBox(height: 12),
                   Text(
                     // Display the probability text
                     'Probability: ${(probabilityValue * 100).toStringAsFixed(2)}%',
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
          : const SizedBox.shrink(), // Show nothing when result is empty or a model error
    );
  }

  // --- Modified _getResultColor to accept boolean ---
  // Returns the color based on the boolean result flag
  Color _getResultColor(bool isHypertensive) {
    if (isHypertensive) {
      return Colors.red; // Red for positive/warning
    } else {
      return Colors.green; // Green for negative/success
    }
  }
  // --- End Modified _getResultColor ---


  Future<void> _handlePrediction() async {
    // Clear previous result and state, start processing indicator
    setState(() {
      _isProcessing = true;
      result = ''; // Clear result text
      probabilityValue = 0.0; // Reset probability
      _isHypertensive = false; // Reset the flag
    });

    // Add a small delay to allow UI to update before potentially blocking
    await Future.delayed(const Duration(milliseconds: 50));

    // Validate form
    if (!_formKey.currentState!.validate()) {
      setState(() {
         _isProcessing = false; // Stop processing if validation fails
      });
      return; // Stop if validation fails
    }

    // Check if model is loaded before running inference
    if (!_isModelLoaded || _interpreter == null) {
         setState(() {
           result = 'Error: Model not loaded. Cannot predict.'; // Update result for prediction failure
           _isProcessing = false;
         });
         return;
    }

    try {
        final rawInputs = [
            double.parse(ageController.text),
            _gender == 'Male' ? 1.0 : 0.0, // Gender: Male=1, Female=0
            _getSmokingValue(_smoking), // Use a helper for smoking
            double.parse(bmiController.text),
            double.parse(cholController.text),
            double.parse(sysBPController.text),
            double.parse(diaBPController.text),
            hasDiabetes ? 1.0 : 0.0
        ];

        // Scaling inputs - **CRITICAL: Ensure _scaleInput matches your model's training scaler!**
        final scaledInputs = _scaleInput(rawInputs);

        // TFLite input buffer shape [1, number_of_features]
        final input = [scaledInputs];

        // TFLite output buffer shape [1, number_of_outputs] (usually [1, 1] for binary classification)
        final output = List.filled(1, 0.0).reshape([1, 1]);

        // Run inference
        _interpreter.run(input, output);

        final prediction = output[0][0]; // Get the single probability value (e.g., 0.75)

        // Determine boolean result and probability percentage for display
        final isHypertensiveResult = prediction >= 0.5; // Use your model's probability threshold (e.g., 0.5)
        final probabilityPercentage = (prediction * 100).toStringAsFixed(2);
        final resultText = isHypertensiveResult
            ? 'Hypertensive'
            : 'Not Hypertensive';

        print("Hypertension Prediction Probability: $prediction ($probabilityPercentage%)");

        // Update state with final result, probability, and the boolean flag
        setState(() {
          probabilityValue = prediction; // Store raw probability
          result = '$resultText ($probabilityPercentage%)'; // Set the result string including percentage
          _isHypertensive = isHypertensiveResult; // <-- Set the boolean flag based on prediction
        });

    } catch (e) {
       setState(() {
         result = 'Prediction failed: ${e.toString()}'; // Show error in result area
         _isHypertensive = false; // Ensure flag is false on error
       });
       print("Hypertension Prediction error: $e");
    } finally {
      setState(() => _isProcessing = false); // Always stop processing
    }
  }

  // Helper function to map smoking status string to numerical value
  double _getSmokingValue(String? smokingStatus) {
      // **CRITICAL: Ensure this mapping matches the encoding used when training your model!**
      switch (smokingStatus) {
          case 'Never': return 0.0;
          case 'Formerly': return 0.5; // Assuming Formerly is 0.5, adjust if your model used 0 or 1
          case 'Smokes': return 1.0;
          default: return 0.0; // Handle null or 'No Info' as Never
      }
  }

  // Example scaling logic - **Verify this matches your model's training scaler!**
  List<double> _scaleInput(List<double> rawInputs) {
      // These min/max values *must* come from the data used to train your hypertension model's scaler.
      // If your model used StandardScaler or MinMaxScaler, these need to match those fit on the training data.
      // The order and values below are placeholders based on typical ranges but might not be correct for your model.
      // Match the order of rawInputs: age, gender, smoking, bmi, chol, sysBP, diaBP, diabetes
      final minValues = [0.0, 0.0, 0.0, 10.0, 100.0, 80.0, 40.0, 0.0]; // Example min for each feature
      final maxValues = [120.0, 1.0, 1.0, 60.0, 500.0, 250.0, 150.0, 1.0]; // Example max for each feature

      if (rawInputs.length != minValues.length || rawInputs.length != maxValues.length) {
           print("Scaling Error: Input length (${rawInputs.length}) doesn't match min/max value lists length (${minValues.length}).");
           // In a real app, you might want to throw an exception or show a user-friendly error
           // For now, we'll just return the raw inputs (prediction will likely be wrong)
           return rawInputs;
      }

      List<double> scaled = [];
      for (int i = 0; i < rawInputs.length; i++) {
          final min = minValues[i];
          final max = maxValues[i];
           // Prevent division by zero if max == min
          if (max == min) {
               // Handle this case - might return 0.0, raw value, or throw error depending on scaler type
               print("Scaling Warning: Max equals Min for feature at index $i. Cannot scale. Returning raw value or 0.0.");
               scaled.add(rawInputs[i]); // Or scaled.add(0.0)
          } else {
              scaled.add((rawInputs[i] - min) / (max - min));
          }
      }
      return scaled;
  }

  // Modified _buildModelError to be more informative and only show load error
  Widget _buildModelError() {
     // This widget is specifically for the initial model *loading* error
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 20),
         child: Text(
           result.isNotEmpty ? result : 'Loading Hypertension model...', // Show the error message from state, or loading text
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

} // End of _HypertensionTestPageState class