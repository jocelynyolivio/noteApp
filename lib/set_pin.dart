import 'package:flutter/material.dart';
import 'enter_pin.dart'; // Import enter_pin.dart
import 'package:hive_flutter/hive_flutter.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({Key? key}) : super(key: key);

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  late List<String> pinEntries;
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    pinEntries = ['', '', '', '']; // Initialize list for 4 PIN digits

    // Add listener to each controller for automatic navigation
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          // Move focus to the next TextField
          FocusScope.of(context).nextFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Initial PIN'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: '', // Hide character counter
                      ),
                      onChanged: (value) {
                        setState(() {
                          pinEntries[index] = value;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String initialPin = pinEntries.join(); // Combine entries into initialPin

                if (initialPin.length == 4) {
                  // Save initial PIN to Hive
                  await Hive.box('myBox').put('initialPin', initialPin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Initial PIN set successfully and saved.'),
                    ),
                  );

                  // Navigate to EnterPinPage after setting initial PIN
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EnterPinPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a 4-digit PIN.'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
