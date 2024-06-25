import 'package:flutter/material.dart';
import 'enter_pin.dart';

class SetInitialPinPage extends StatefulWidget {
  const SetInitialPinPage({Key? key}) : super(key: key);

  @override
  _SetInitialPinPageState createState() => _SetInitialPinPageState();
}

class _SetInitialPinPageState extends State<SetInitialPinPage> {
  late String initialPin;

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
                if (initialPin.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EnterPinPage(initialPin: initialPin)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please set an initial PIN.'),
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
