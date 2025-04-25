// heart_disease_test_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// Import the PositiveResultPage for navigation when risk is positive
import 'heart_result.dart';


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

  String result = ''; // Stores the result text, now includes percentage
  double probabilityValue = 0.0; // Stores the raw probability (0.0 to 1.0)
  bool _isPositiveResult = false; // <-- NEW: Flag to track if the result is Positive

  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController; // For result display animation
  late Animation<double> _resultAnimation; // For result display animation

  // Update asset path if necessary
  final String _modelPath = 'assets/assets/Heart.tflite'; // Ensure this path is correct

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
    // Dispose the interpreter only if it was successfully loaded and assigned
    if (_isModelLoaded && _interpreter != null) {
      _interpreter.close();
    }
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
      final interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: InterpreterOptions()..threads = 4,
      );
      final inputTensors = interpreter.getInputTensors();
      // Expecting input shape [1, 12]
      if (inputTensors.isEmpty || inputTensors[0].shape.isEmpty || inputTensors[0].shape[1] != 12) {
        throw Exception('Invalid input shape. Expected [1, 12]');
      }
      _interpreter = interpreter; // Assign only on success
      setState(() => _isModelLoaded = true);
      print('Heart disease model loaded successfully from $_modelPath!');
    } catch (e) {
      setState(() {
        result = 'Model Load Error: ${e.toString()}'; // Set error message to result
        _isModelLoaded = false;
      });
      print('Model loading error from $_modelPath: $e');
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
      iconTheme: const IconThemeData(color: Colors.white), // Added for back button color
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
                _buildInputSection(), // Contains inputs and Predict button
                const SizedBox(height: 30),

                // Show model error if it failed to load
                 if (!_isModelLoaded && result.isNotEmpty && result.startsWith('Model Load Error')) ...[
                     _buildModelError(), // Use the specific error builder
                     const SizedBox(height: 20), // Add spacing
                 ],

                _buildResultDisplay(), // Displays the prediction result and probability

                // --- Conditional Continue Button ---
                // Show button ONLY if the _isPositiveResult flag is true
                if (_isPositiveResult) ...[ // <-- Use the boolean flag
                    const SizedBox(height:25),
                    _buildContinueButton(), // <-- Call the button widget
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
          _buildPredictButton(), // Button is inside the input section
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.black87),
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
        if (value == null || value.isEmpty) return 'Please enter a value';
        final numValue = double.tryParse(value);
        if (numValue == null) return 'Invalid number';
        if (numValue < validatorMin || numValue > validatorMax)
          return 'Value must be between ${validatorMin.toStringAsFixed(0)} and ${validatorMax.toStringAsFixed(0)}';
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
    );
  }

  Widget _buildSwitchInput(String label, bool value, Function(bool) onChanged) {
     return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.black87)), // Ensure text color
      value: value,
      activeColor: const Color(0xFF6C63FF),
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: EdgeInsets.zero, // Remove default padding
      onChanged: onChanged,
    );
  }

  // --- NEW Continue Button Widget ---
  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the PositiveResultPage (same advice page as diabetes/hypertension)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PositiveResultPage()),
        );
      },
       style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 35),
        backgroundColor: Colors.orangeAccent, // Consistent color with other pages
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
          color: Colors.white // Ensure text color is white
        ),
      ),
    );
  }
  // --- End NEW Continue Button Widget ---


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
                  fontWeight: FontWeight.w600,
                  color: Colors.white)), // Ensure text color is white
    );
  }

  // --- Modified _buildResultDisplay ---
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
       // Show the result box only if result is not empty AND not a model error
      child: result.isNotEmpty && !result.startsWith('Model Load Error')
          ? Container(
              key: ValueKey<String>(result), // Key based on the result string for animation
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                // Use color based on the _isPositiveResult flag
                color: _getResultColor(_isPositiveResult).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _getResultColor(_isPositiveResult), // Use color based on flag
                    width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                     // Choose icon based on the _isPositiveResult flag
                    _isPositiveResult
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle,
                    color: _getResultColor(_isPositiveResult), // Use color based on flag
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result, // Display the result string (includes percentage)
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(_isPositiveResult)), // Use color based on flag
                     textAlign: TextAlign.center, // Center align text
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: probabilityValue,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getResultColor(_isPositiveResult)), // Use color based on flag
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
          : const SizedBox.shrink(), // Show nothing when result is empty or a model error
    );
  }
  // --- End Modified _buildResultDisplay ---


  // --- Modified _getResultColor to accept boolean ---
  Color _getResultColor(bool isPositive) {
    if (isPositive) {
      return Colors.red; // Red for Positive
    } else {
      return Colors.green; // Green for Negative
    }
  }
  // --- End Modified _getResultColor ---


  Widget _buildModelError() {
     // This widget is specifically for the initial model *loading* error
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 20),
         child: Text(
           result.isNotEmpty ? result : 'Loading Heart Disease model...', // Show the error message from state, or loading text
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


  Future<void> _handlePrediction() async {
    // Clear previous result and state, start processing indicator
    setState(() {
      _isProcessing = true;
      result = ''; // Clear result text
      probabilityValue = 0.0; // Reset probability
      _isPositiveResult = false; // <-- Reset the flag
      _animationController.reset(); // Reset animation
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
      // Collect the 12 inputs in the required order:
      // [gender, age, currentSmoker, cigsPerDay, BPMeds, diabetes, totChol, sysBP, diaBP, BMI, heartRate, glucose]
      // **CRITICAL: Ensure this order exactly matches the input layer of your TFLite model!**
      final rawInputs = [
        _gender == 'Male' ? 1.0 : 0.0, // Assuming Male is 1.0, Female is 0.0
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

      // Your model might expect scaled inputs. Check how it was trained.
      // If it expects raw inputs, remove the scaling step.
      // If it expects scaled inputs (like with StandardScaler or MinMaxScaler), implement the correct scaling here.
      // For now, assuming raw inputs based on the structure, but be cautious.
      final input = [rawInputs]; // Model expects shape [1, 12]

      // TFLite output buffer, expecting a single probability value [1, 1]
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);

      final probability = output[0][0]; // Get the single probability value

      // Determine boolean result and probability percentage for display
      final isPositive = probability >= 0.5; // <-- Use your model's probability threshold (e.g., 0.5)
      final probabilityPercentage = (probability * 100).toStringAsFixed(2);
      final resultText = isPositive
          ? 'Positive'
          : 'Negative';


      // Update state with final result, probability, and the boolean flag
      setState(() {
        probabilityValue = probability; // Store raw probability
        result = '$resultText ($probabilityPercentage%)'; // Set the result string including percentage
        _isPositiveResult = isPositive; // <-- Set the boolean flag based on prediction
      });

      _animationController.forward(); // Start the result animation

    } catch (e) {
      setState(() {
         result = 'Prediction failed: ${e.toString()}'; // Show error in result area
         _isPositiveResult = false; // Ensure flag is false on error
      });
      print("Prediction error: $e");
    } finally {
      setState(() => _isProcessing = false); // Always stop processing
    }
  }
}