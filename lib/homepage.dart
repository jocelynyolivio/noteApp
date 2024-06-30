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
        return bTimestamp
            .compareTo(aTimestamp); // Sort by last modified in descending order
      });
    }
  }

  void deleteData(String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Confirm Delete', style: TextStyle(color: Colors.teal)),
          content: Text('Are you sure you want to delete this entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without deleting
              },
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800], // Tosca green accent
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog before deleting
                _container.delete(key);
                getAllEntries(); // Update the list after deleting
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title:
            const Text('Confirm Logout', style: TextStyle(color: Colors.teal)),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without logging out
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800], // Tosca green accent
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog before logging out
              performLogout(); // Execute logout function after confirmation
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
          ),
        ],
      ),
    );
  }

  void performLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnterPinPage(), // Replace with appropriate page
      ),
    );
  }

  void resetPin() async {
    final storedPin = await Hive.box('myBox').get('initialPin');

    List<TextEditingController> pinControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Change PIN',
            style: TextStyle(color: Colors.teal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('Please enter your current PIN:'),
            Row(
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
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        // Auto move focus to the next TextField
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        // Auto move focus to the previous TextField on deletion
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without changing PIN
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800], // Tosca green accent
            ),
            onPressed: () {
              String enteredPin = pinControllers.map((e) => e.text).join();
              if (enteredPin == storedPin) {
                Navigator.of(context)
                    .pop(); // Close dialog after PIN confirmation
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
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white), // Text color set to white
            ),
          ),
        ],
      ),
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
        backgroundColor: Colors.teal[800],
        title: const Text(
          'Notes',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            icon: const Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.white,
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                _sortCriteria = newValue!;
                sortEntries();
              });
            },
            items: <String>['title', 'lastModified']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'title' ? 'Sort by Title' : 'Sort by Last Modified',
                  style: TextStyle(
                    color: _sortCriteria == value
                        ? Colors.teal[800]
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
            style: TextStyle(color: Colors.black),
            elevation: 4,
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset, color: Colors.white),
            onPressed: resetPin,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          final creationDate = data?['creationDate'];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.green[100], // Light teal color
            child: ListTile(
              title: Text(
                key,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value ?? ''),
                  const SizedBox(height: 5),
                  Text(
                    'Created: ${creationDate ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    'Last Modified: ${timestamp ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => editData(key),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () =>
                        deleteData(key), // Call deleteData with key
                  ),
                ],
              ),
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
            getAllEntries();
          });
        },
        backgroundColor: Colors.teal[800], // Lighter teal color
        child: Icon(
          Icons.add,
          color: Colors.white, // Set icon color to white
        ),
      ),
    );
  }
}
