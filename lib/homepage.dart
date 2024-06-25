import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'entry_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  final _aKey = TextEditingController();
  List<String> allEntries = [];

  void getAllEntries() {
    setState(() {
      allEntries = _myBox.keys.cast<String>().toList();
    });
  }

  void deleteData(String key) {
    _myBox.delete(key);
    getAllEntries(); // Update the list after deleting
  }

  void editData(String key) {
    String? initialValue = _myBox.get(key);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryFormPage(
          initialTitle: key,
          initialContent: initialValue,
        ),
      ),
    ).then((_) {
      getAllEntries(); // Refresh list after returning from EntryFormPage
    });
  }

  @override
  void initState() {
    super.initState();
    getAllEntries(); // Initial loading of entries
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entries'),
      ),
      body: ListView.builder(
        itemCount: allEntries.length,
        itemBuilder: (context, index) {
          final key = allEntries[index];
          final value = _myBox.get(key);
          return ListTile(
            title: Text(key),
            subtitle: Text(value ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => editData(key),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteData(key),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntryFormPage()),
          ).then((_) {
            getAllEntries(); // Refresh list after returning from EntryFormPage
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
