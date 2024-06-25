// test awal buat pin (jdinya yg dipak set sm enter)
import 'package:flutter/material.dart';
import 'homepage.dart';

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
    initialPin = ''; // Atur nilai default atau kosong untuk PIN awal
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
                    initialPin = value; // Menyimpan PIN awal dari input pengguna
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Initial PIN set successfully.'),
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
                    enteredPin = value; // Menyimpan PIN yang dimasukkan pengguna
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (enteredPin == initialPin) {
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
