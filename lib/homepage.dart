import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'entry_form_page.dart';
import 'enter_pin.dart';
import 'set_pin.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _container = Hive.box('container');
  List<String> allEntries = [];
  String _sortCriteria = 'title'; // Default sorting by title

// mengeluarkan semua notes
  void getAllEntries() {
    setState(() {
      allEntries = _container.keys.cast<String>().toList();
      sortEntries();
    });
  }

// untuk sorting default title, bisa lastModified
  void sortEntries() {
    if (_sortCriteria == 'title') {
      allEntries.sort();
    } else if (_sortCriteria == 'lastModified') {
      allEntries.sort((a, b) {
        final aData = _container.get(a);
        final bData = _container.get(b);
        final aTimestamp = aData['timestamp'];
        final bTimestamp = bData['timestamp'];
        return bTimestamp.compareTo(aTimestamp); //desc
      });
    }
  }

// untuk delete data dengan modal/dialog
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _container.delete(key);
                getAllEntries(); // Update list setelah delete
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

// untuk edit data -> redirect ke page lain
  void editData(String key) {
    Map? data = _container.get(key); // ambil dari hive bedasarkan key

    String? initialTitle = data?['title']; // title
    String? initialContent = data?['content']; // content

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryFormPage(
          initialKey: key, // Meneruskan key yang asli
          initialTitle: initialTitle, // Meneruskan title yang asli
          initialContent: initialContent, // Meneruskan content yang asli
        ),
      ),
    ).then((_) {
      getAllEntries(); // Update List
    });
  }

// logout dengan dialog dan kembali ke enter_pin
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterPinPage(),
                ),
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

// reset harus masukkan current pin dulu bentuk modal
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
                      counterText: '',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
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
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[800],
            ),
            onPressed: () {
              String enteredPin = pinControllers.map((e) => e.text).join();
              // cek kalau benar current pin nya
              if (enteredPin == storedPin) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  // baru boleh set_pin
                  MaterialPageRoute(builder: (context) => SetPinPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor:
                        Colors.red,
                    content: Text(
                      'Incorrect PIN. Please try again.',
                      style: TextStyle(
                          color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
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
          final title = data?['title'];
          final value = data?['content'];
          final timestamp = data?['timestamp'];
          final creationDate = data?['creationDate'];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.green[100],
            child: ListTile(
              title: Text(
                title,
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
                        deleteData(key), // deleteData with key
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
        backgroundColor: Colors.teal[800],
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
