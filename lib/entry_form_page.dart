import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class EntryFormPage extends StatefulWidget {
  final String? initialKey; // unique key biar bisa title sama dan edit masing"
  final String? initialTitle;
  final String? initialContent;

  EntryFormPage({this.initialKey, this.initialTitle, this.initialContent});

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
    _contentController =TextEditingController(text: widget.initialContent ?? '');
  }

  void writeData(BuildContext context) {
  final _myBox = Hive.box('container');
  final currentTimestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

  //input tidak boleh kosong
  if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Title and content cannot be empty.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return;
  }

  //kalau title kosong auto new note 
  if(_titleController.text.isEmpty){
    _titleController.text = "New Note";
  }

  // Lanjutkan dengan menyimpan data
  if (widget.initialKey == null) {
    // unique key
    String newKey = DateTime.now().millisecondsSinceEpoch.toString();
    _myBox.put(newKey, {
      'title': _titleController.text,
      'content': _contentController.text,
      'timestamp': currentTimestamp,
      'creationDate': currentTimestamp,
    });
  } else {
    // Mengedit entry yang sudah ada
    final existingData = _myBox.get(widget.initialKey);
    String creationDate = existingData['creationDate']; // Mengambil tanggal pembuatan yang sudah ada

    _myBox.put(widget.initialKey, {
      'title': _titleController.text,
      'content': _contentController.text,
      'timestamp': currentTimestamp, // Waktu saat ini untuk timestamp
      'creationDate': creationDate, // tidak berubah
    });
  }
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialKey == null ? 'Add Entry' : 'Edit Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[800],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
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
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.initialKey == null ? 'Write' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
