import 'package:flutter/material.dart';
import 'homepage.dart';

class EnterPinPage extends StatefulWidget {
  final String initialPin;

  const EnterPinPage({Key? key, required this.initialPin}) : super(key: key);

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  String enteredPin = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your PIN'),
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
                  labelText: 'Enter PIN',
                ),
                onChanged: (value) {
                  setState(() {
                    enteredPin = value; // Menyimpan PIN yang dimasukkan pengguna
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (enteredPin == widget.initialPin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
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
