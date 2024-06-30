import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EnterPinPage extends StatefulWidget {
  const EnterPinPage({Key? key}) : super(key: key);

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  late List<String> pinEntries; // List untuk pin
  final List<TextEditingController> _controllers = [
    //TextField
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<FocusNode> _focusNodes = [
    // List untuk auto pindah focus
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    pinEntries = ['', '', '', '']; // Inisialisasi 4 digit PIN
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      // Memastikan untuk dispose semua controller
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      // Memastikan untuk dispose semua focus node
      focusNode.dispose();
    }
    super.dispose();
  }

  // Perubahan pada TextField
  void _handleTextFieldChange(String value, int index) {
    setState(() {
      pinEntries[index] = value;
    });

    if (value.isNotEmpty && index < _controllers.length - 1) {
      _focusNodes[index + 1]
          .requestFocus(); // Pindah fokus ke TextField berikutnya jika tidak kosong
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1]
          .requestFocus(); // Pindah fokus ke TextField sebelumnya jika kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Enter PIN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter Your PIN',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 69, 62)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[
                          index], // Menggunakan controller sesuai index
                      focusNode: _focusNodes[
                          index], // Menggunakan focus node sesuai index
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        counterText: '',
                      ),

                      onChanged: (value) {
                        // onchange panggil function
                        _handleTextFieldChange(value, index);
                      },
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredPin =
                    pinEntries.join(); // Menggabungkan entri menjadi enteredPin
                final storedPin = Hive.box('myBox')
                    .get('initialPin'); // Mendapatkan initialPin dari Hive

                if (enteredPin == storedPin) {
                  Navigator.push(
                    // Navigate ke halaman HomePage jika PIN benar
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // Tampilkan Snackbar jika PIN salah
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Incorrect PIN. Please try again.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
