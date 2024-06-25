import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    final _myBox = Hive.box('mybox');
    if (widget.initialTitle == null) {
      // Adding new entry
      _myBox.put(_titleController.text, _contentController.text);
    } else {
      // Editing existing entry
      String oldTitle = widget.initialTitle!;
      String? oldValue = _myBox.get(oldTitle);
      
      // Check if title has changed
      if (_titleController.text != oldTitle) {
        _myBox.delete(oldTitle); // Delete old entry if title has changed
      }
      
      _myBox.put(_titleController.text, _contentController.text);
    }
    Navigator.pop(context); // Return to HomePage after writing data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTitle == null ? 'Add Entry' : 'Edit Entry'),
      ),
      body: Padding(
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
              child: Text(widget.initialTitle == null ? 'Write' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
