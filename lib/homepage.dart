import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'entry_form_page.dart';
import 'enter_pin.dart'; // Import enter_pin.dart
import 'set_pin.dart'; // Import set_pin.dart

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _container = Hive.box('container');
  List<String> allEntries = [];
  String _sortCriteria = 'title'; // Default sorting by title

  void getAllEntries() {
    setState(() {
      allEntries = _container.keys.cast<String>().toList();
      sortEntries();
    });
  }

  void sortEntries() {
    if (_sortCriteria == 'title') {
      allEntries.sort();
    } else if (_sortCriteria == 'lastModified') {
      allEntries.sort((a, b) {
        final aData = _container.get(a);
        final bData = _container.get(b);
        final aTimestamp = aData['timestamp'];
        final bTimestamp = bData['timestamp'];
        return bTimestamp.compareTo(aTimestamp); // Sort by last modified in descending order
      });
    }
  }

  void deleteData(String key) {
    _container.delete(key);
    getAllEntries(); // Update the list after deleting
  }

  void editData(String key) {
    Map? data = _container.get(key);
    String? initialContent = data?['content'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryFormPage(
          initialTitle: key,
          initialContent: initialContent,
        ),
      ),
    ).then((_) {
      getAllEntries(); // Refresh list after returning from EntryFormPage
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EnterPinPage()), // Ganti dengan halaman yang sesuai
    );
  }

  void resetPin() async {
    final storedPin = await Hive.box('myBox').get('initialPin');

    showDialog(
      context: context,
      builder: (context) {
        final List<TextEditingController> pinControllers = [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ];

        return AlertDialog(
          title: const Text('Enter Current PIN'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 50,
                child: TextField(
                  controller: pinControllers[index],
                  obscureText: true,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    counterText: '', // Hide character counter
                  ),
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String enteredPin = pinControllers.map((e) => e.text).join();
                if (enteredPin == storedPin) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetPinPage()),
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
        );
      },
    );
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
      automaticallyImplyLeading: false,
      title: const Text('Entries'),
      actions: [
        DropdownButton<String>(
          value: _sortCriteria,
          icon: const Icon(Icons.sort, color: Colors.white),
          dropdownColor: Colors.blue,
          underline: Container(),
          onChanged: (String? newValue) {
            setState(() {
              _sortCriteria = newValue!;
              sortEntries(); // Sort entries based on selected criteria
            });
          },
          items: <String>['title', 'lastModified']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'title' ? 'Sort by Title' : 'Sort by Last Modified'),
            );
          }).toList(),
        ),
        IconButton(
          icon: const Icon(Icons.lock_reset),
          onPressed: resetPin,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: logout,
        ),
      ],
    ),
    body: ListView.builder(
      itemCount: allEntries.length,
      itemBuilder: (context, index) {
        final key = allEntries[index];
        final data = _container.get(key);
        final value = data?['content'];
        final timestamp = data?['timestamp'];
        final creationDate = data?['creationDate']; // Mengambil tanggal pembuatan

        return ListTile(
          title: Text(key),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value ?? ''),
              const SizedBox(height: 5),
              const Text(
                'Created:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                creationDate ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              const Text(
                'Last Modified:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                timestamp ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editData(key),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
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
      child: const Icon(Icons.add),
    ),
  );
}}