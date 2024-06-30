import 'package:flutter/material.dart';
import 'enter_pin.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({Key? key}) : super(key: key);

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  late List<String> pinEntries; // List untuk pin
  final List<TextEditingController> _controllers = [//textfield
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // List untuk auto pindah focus
  final List<FocusNode> _focusNodes = [
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

  // Meng-handle perubahan pada TextField
  void _handleTextFieldChange(String value, int index) {
    setState(() {
      pinEntries[index] =
          value; // Mengupdate nilai PIN sesuai dengan input user
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
        title: const Text(
          'Set Initial PIN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Create Your PIN',
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
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () async {
                String initialPin =
                    pinEntries.join(); // Menggabungkan entri menjadi initialPin

                if (initialPin.length == 4) {
                  // Save initial PIN ke Hive
                  await Hive.box('myBox').put('initialPin', initialPin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor:
                          Colors.green, // Mengatur warna latar belakang hijau
                      content: Text(
                        'Initial PIN set successfully and saved.',
                        style: TextStyle(
                            color: Colors.white), // Mengatur warna teks putih
                      ),
                    ),
                  );

                  // Navigate ke halaman EnterPinPage setelah setting initial PIN berhasil
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EnterPinPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    // exception
                    const SnackBar(
                      backgroundColor:
                          Colors.red, // Mengatur warna latar belakang merah
                      content: Text(
                        'Please enter a 4-digit PIN.',
                        style: TextStyle(
                            color: Colors.white), // Mengatur warna teks putih
                      ),
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
