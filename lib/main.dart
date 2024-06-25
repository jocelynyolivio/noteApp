import 'package:flutter/material.dart';
import 'pin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'set_pin.dart';

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
      home: SetInitialPinPage(), // Menggunakan PinPage sebagai halaman utama
    );
  }
}

