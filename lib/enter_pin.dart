import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EnterPinPage extends StatefulWidget {
  const EnterPinPage({Key? key}) : super(key: key);

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  late List<String> pinEntries;
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    pinEntries = ['', '', '', '']; // for 4 PIN digits
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextFieldChange(String value, int index) {
    setState(() {
      pinEntries[index] = value;
    });

    if (value.isNotEmpty && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Enter PIN',
          style: TextStyle(color: Colors.white), // Warna teks hijau tosca muda
        ),
        backgroundColor: Colors.teal[800], // Hijau tosca gelap
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter Your PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 69, 62)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: '', // Hide character counter
                      ),
                      onChanged: (value) {
                        _handleTextFieldChange(value, index);
                      },
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredPin = pinEntries.join(); // Combine entries into enteredPin
                final storedPin = Hive.box('myBox').get('initialPin');

                if (enteredPin == storedPin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect PIN. Please try again.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700], // Hijau tosca gelap
                foregroundColor: Colors.white, // Warna teks
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
