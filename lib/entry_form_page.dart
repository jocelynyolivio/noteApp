import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Tambahkan import ini untuk format tanggal

class EntryFormPage extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;

  EntryFormPage({this.initialTitle, this.initialContent});

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');
  }

  void writeData(BuildContext context) {
  final _myBox = Hive.box('container');
  final currentTimestamp = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

  if (widget.initialTitle == null) {
    // Menambahkan entry baru
    _myBox.put(_titleController.text, {
      'content': _contentController.text,
      'timestamp': currentTimestamp,
      'creationDate': currentTimestamp // Menyimpan tanggal pembuatan
    });
  } else {
    // Mengedit entry yang sudah ada
    String oldTitle = widget.initialTitle!;
    final existingData = _myBox.get(oldTitle);
    String creationDate = existingData['creationDate']; // Mengambil tanggal pembuatan yang sudah ada

    if (_titleController.text != oldTitle) {
      _myBox.delete(oldTitle); // Menghapus entry lama jika judulnya berubah
    }

    _myBox.put(_titleController.text, {
      'content': _contentController.text,
      'timestamp': currentTimestamp,
      'creationDate': creationDate // Mempertahankan tanggal pembuatan yang sudah ada
    });
  }
  Navigator.pop(context); // Kembali ke HomePage setelah menulis data
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialTitle == null ? 'Add Entry' : 'Edit Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      body: Container(
        // color: Colors.teal[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                controller: _titleController,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Content',
                ),
                controller: _contentController,
                maxLines: null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => writeData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700], // Hijau tosca gelap
                  foregroundColor: Colors.white, // Warna teks tombol
                ),
                child: Text(widget.initialTitle == null ? 'Write' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
