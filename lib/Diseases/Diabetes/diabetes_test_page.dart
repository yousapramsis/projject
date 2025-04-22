import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'positive_result_page.dart';

class DiabetesTestPage extends StatefulWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);
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

  // Feature‐scaling metadata (unchanged)
  final _featureNames = [
    'age','bmi','hypertension','heart_disease',
    'HbA1c_level','blood_glucose_level',
    'gender_Male','smoking_history_current'
  ];
  final _means = {
    'age':41.88646,'bmi':27.320767,'hypertension':0.07485,
    'heart_disease':0.03942,'HbA1c_level':5.52777,
    'blood_glucose_level':138.05806,'gender_Male':0.58579,
    'smoking_history_current':0.09166
  };
  final _stds = {
    'age':22.51684,'bmi':6.698994,'hypertension':0.26315,
    'heart_disease':0.194593,'HbA1c_level':1.070672,
    'blood_glucose_level':40.70913,'gender_Male':0.492592,
    'smoking_history_current':0.288553
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
      if (inputTensors.length!=1||inputTensors[0].shape[1]!=8) {
        throw Exception('Model expects [1,8] inputs');
      }
      setState(() => _isModelLoaded = true);
    } catch (e) {
      setState(() {
        result = 'Model Error: $e';
        _isModelLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Risk Assessment'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
             colors:[Color(0xFF6C63FF),Color(0xFF4A90E2)],
             begin:Alignment.topLeft,end:Alignment.bottomRight))),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:Alignment.topCenter,
            end:Alignment.bottomCenter,
            colors:[Color(0xFFF8F9FF),Color(0xFFE6E9FF)])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:CrossAxisAlignment.stretch,
                children:[
                  _buildHeader(),
                  const SizedBox(height:30),
                  _buildInputsCard(),
                  const SizedBox(height:30),
                  if(!_isModelLoaded) _buildError(),
                  _buildResult(),
                  if(result.toLowerCase().contains('positive'))...[
                    const SizedBox(height:25),
                    _buildContinueButton(),
                  ],
                  const SizedBox(height:20),
                ])))),
      ),
    );
  }

  Widget _buildHeader() => Column(children:[
    const Icon(Icons.health_and_safety,size:70,color:Color(0xFF6C63FF)),
    const SizedBox(height:20),
    Text('Diabetes Risk Assessment',
      style: Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontSize:28,fontWeight:FontWeight.bold),
      textAlign: TextAlign.center),
    const SizedBox(height:12),
    Text('Provide accurate health information for reliable results',
      style:TextStyle(fontSize:16,color:Colors.grey[600],height:1.5),
      textAlign: TextAlign.center),
  ]);

  Widget _buildInputsCard() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color:Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow:[BoxShadow(color:Colors.grey.withOpacity(0.2),
        blurRadius:25,spreadRadius:5)],
    ),
    child: Column(children:[
      _buildDropdown('Gender', ['Male','Female'], _gender,
        (v)=>setState(()=>_gender=v)),
      const SizedBox(height:20),
      _buildDropdown('Smoking History',['Never','Current','Former','No Info'],
        _smokingHistory,(v)=>setState(()=>_smokingHistory=v)),
      const SizedBox(height:20),
      _buildNumberInput(ageController,'Age','cake',0,100),
      const SizedBox(height:15),
      _buildNumberInput(bmiController,'BMI','monitor_weight',10,60),
      const SizedBox(height:15),
      _buildNumberInput(hba1cController,'HbA1c (%)','bloodtype',3,10),
      const SizedBox(height:15),
      _buildNumberInput(glucoseController,'Glucose (mg/dL)','favorite',50,400),
      const SizedBox(height:15),
      _buildNumberInput(cholesterolController,'Cholesterol (mg/dL)','water_drop',0,500),
      const SizedBox(height:15),
      _buildNumberInput(ldlController,'LDL (mg/dL)','layers',0,300),
      const SizedBox(height:15),
      _buildNumberInput(triglyceridesController,'Triglycerides (mg/dL)','bubble_chart',0,500),
      const SizedBox(height:15),
      _buildNumberInput(hdlController,'HDL (mg/dL)','circle',0,200),
      const SizedBox(height:20),
      _buildSwitch('Hypertension',hasHypertension,
        (v)=>setState(()=>hasHypertension=v!)),
      _buildSwitch('Heart Disease',hasHeartDisease,
        (v)=>setState(()=>hasHeartDisease=v!)),
      const SizedBox(height:30),
      ElevatedButton(
        onPressed:_isModelLoaded&&!_isProcessing?_predict:null,
        child:_isProcessing?
          const SizedBox(width:25,height:25,child:CircularProgressIndicator()):
          const Text('Check Risk'),
      ),
    ]),
  );

  Widget _buildDropdown(String label,List<String> opts,String? val,ValueChanged<String?> onChanged){
    return DropdownButtonFormField<String>(
      value: val,
      decoration: InputDecoration(labelText:label,filled:true,fillColor:Color(0xFFF8F9FF)),
      items: opts.map((o)=>DropdownMenuItem(value:o,child:Text(o))).toList(),
      validator:(v)=>v==null?'Select $label':null,
      onChanged:onChanged,
    );
  }

  Widget _buildNumberInput(TextEditingController c, String label,String iconName,
      double min,double max){
    return TextFormField(
      controller:c,
      keyboardType:TextInputType.numberWithOptions(decimal:true),
      decoration:InputDecoration(
        labelText:label,
        prefixIcon:Icon(IconData(
          IconsMap[iconName]!, // see note below
          fontFamily:'MaterialIcons'
        )),
        filled:true,fillColor:Color(0xFFF8F9FF),
      ),
      validator:(v)=>_validateRange(v,min,max),
    );
  }

  // helper map for icons:
  static const Map<String,int> IconsMap = {
    'cake':0xe7fb,'monitor_weight':0xeb44,
    'bloodtype':0xec37,'favorite':0xe87d,
    'water_drop':0xec11,'layers':0xe53a,
    'bubble_chart':0xe7b7,'circle':0xe83f
  };

  Widget _buildSwitch(String label,bool val,ValueChanged<bool?> onChanged){
    return SwitchListTile(title:Text(label),value:val,
      activeColor:Color(0xFF6C63FF),onChanged:onChanged);
  }

  Widget _buildError()=>Center(child:Text(result,
    style:TextStyle(color:Colors.redAccent,fontWeight:FontWeight.bold)));

  Widget _buildResult()=>AnimatedSwitcher(
    duration:const Duration(milliseconds:500),
    child: result.isEmpty?SizedBox.shrink():Container(
      padding:const EdgeInsets.all(25),
      decoration:BoxDecoration(
        color:_getColor().withOpacity(0.1),
        border:Border.all(color:_getColor(),width:2),
        borderRadius:BorderRadius.circular(20),
      ),
      child:Column(children:[
        Icon(result.contains('Positive')?Icons.warning:Icons.check,
            color:_getColor(),size:60),
        const SizedBox(height:20),
        Text(result,style:TextStyle(color:_getColor(),fontSize:24)),
        const SizedBox(height:12),
        LinearProgressIndicator(value:probabilityValue),
        const SizedBox(height:12),
        Text('Probability: ${(probabilityValue*100).toStringAsFixed(2)}%'),
      ]),
    ),
  );

  Widget _buildContinueButton()=>ElevatedButton(
    onPressed:()=>Navigator.push(context,
      MaterialPageRoute(builder:(_)=>const PositiveResultPage())),
    child:const Text('Continue for Advice'),
  );

  Color _getColor(){
    if(result.contains('Positive'))return Colors.red;
    if(result.contains('Negative'))return Colors.green;
    return Colors.grey;
  }

  String? _validateRange(String? v,double min,double max){
    if(v==null||v.isEmpty)return 'Enter a value';
    final n=double.tryParse(v);
    if(n==null)return 'Invalid number';
    if(n<min||n>max)return 'Must be $min–$max';
    return null;
  }

  List<double> _standardizeInputs(List<double> raw){
    final map=Map.fromIterables(_featureNames,raw);
    return _featureNames.map((f){
      final std=_stds[f]!;
      return std==0?0.0:(map[f]! - _means[f]!) / std;
    }).toList();
  }

  Future<void> _predict() async {
    if(!_formKey.currentState!.validate()) return;
    setState(()=>{_isProcessing=true,result='',_animationController.reset()});
    await Future.delayed(const Duration(milliseconds:50));

    // Lipid cutoffs
    final chol=double.tryParse(cholesterolController.text) ?? 0;
    final ldl =double.tryParse(ldlController.text) ?? 0;
    final tri =double.tryParse(triglyceridesController.text) ?? 0;
    final hdl =double.tryParse(hdlController.text) ?? double.infinity;
    if(chol>200||ldl>100||tri>150||hdl<40){
      setState((){
        probabilityValue=1.0;
        result='Positive (100.00%)';
        _isProcessing=false;
      });
      _animationController.forward();
      return;
    }

    final rawInputs=[
      double.parse(ageController.text),
      double.parse(bmiController.text),
      hasHypertension?1.0:0.0,
      hasHeartDisease?1.0:0.0,
      double.parse(hba1cController.text),
      double.parse(glucoseController.text),
      _gender=='Male'?1.0:0.0,
      _smokingHistory=='Current'?1.0:0.0,
    ];
    final input=[_standardizeInputs(rawInputs)];
    final output=[List<double>.filled(1,0.0)];
    _interpreter.run(input,output);
    final p=output[0][0];
    final perc=(p*100).toStringAsFixed(2);
    setState((){
      probabilityValue=p;
      result=p>=0.4?'Positive ($perc%)':'Negative ($perc%)';
      _isProcessing=false;
    });
    _animationController.forward();
  }
}
