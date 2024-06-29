// test saja, jadinya pakai set_pin dan enter_pin
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PinPage extends StatefulWidget {
  const PinPage({Key? key}) : super(key: key);

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  late String initialPin;
  String enteredPin = '';

  @override
  void initState() {
    super.initState();
    initialPin = ''; // Set default or empty initial PIN
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
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Set Initial PIN',
                ),
                onChanged: (value) {
                  setState(() {
                    initialPin = value; // Save initial PIN from user input
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save initial PIN to Hive
                await Hive.box('myBox').put('initialPin', initialPin);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Initial PIN set successfully and saved.'),
                  ),
                );
              },
              child: const Text('Submit'),
            ),

            const SizedBox(height: 20),
            const Text(
              'Enter Your PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter PIN',
                ),
                onChanged: (value) {
                  setState(() {
                    enteredPin = value; // Save entered PIN from user input
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
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
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
