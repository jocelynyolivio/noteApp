import 'package:flutter/material.dart';
import 'pin.dart'; // Mengimpor file pin.dart
import 'homepage.dart'; // Mengimpor homepage.dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PinPage(), // Menggunakan PinPage sebagai halaman utama
    );
  }
}

// HomePage bisa tetap di-import dan digunakan di sini jika Anda ingin menambahkan navigasi kembali ke PinPage setelah logout atau sejenisnya.
