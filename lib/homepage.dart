import 'package:cf_visualizer/sql_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // All Users
  List<Map<String, dynamic>> _users = [];

  bool _isLoading = true;

  Future<void> _refreshAll() async {
    for (int i = 0; i < _users.length; i++) {
      await _updateItem(_users[i]['id'], _users[i]['username']);
    }
  }

  // Fetch all data from database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _usernameController = TextEditingController();

  // Called for Create & Update
  void _showForm(int? id) async {
    // id == null -> create new User
    // id != null -> update an existing User
    if (id != null) {
      final existingJournal =
          _users.firstWhere((element) => element['id'] == id);
      _usernameController.text = existingJournal['username'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // this will prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(hintText: 'Enter username'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                // Clear the text fields
                _usernameController.text = '';
                // Close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_usernameController.text);
    _refreshJournals();
  }

  // Update an existing User
  Future<void> _updateItem(int id, String username) async {
    await SQLHelper.updateItem(id, username);
    _refreshJournals();
  }

  // Delete an User
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshJournals();
  }

  Color _colorforRating(int rating) {
    Color color = Colors.white;
    if (rating < 0) {
      color = Colors.pink;
    } else if (rating < 1200) {
      color = Colors.grey;
    } else if (rating >= 1200 && rating < 1400) {
      color = Colors.green;
    } else if (rating >= 1400 && rating < 1600) {
      color = const Color.fromARGB(255, 3, 168, 158);
    } else if (rating >= 1600 && rating < 1900) {
      color = const Color.fromARGB(255, 0, 0, 255);
    } else if (rating >= 1900 && rating < 2100) {
      color = const Color.fromARGB(255, 128, 0, 128);
    } else if (rating >= 2100 && rating < 2300) {
      color = const Color.fromARGB(255, 255, 165, 0);
    } else if (rating >= 2300 && rating < 2600) {
      color = const Color.fromARGB(255, 255, 165, 0);
    } else if (rating >= 2600 && rating < 2900) {
      color = const Color.fromARGB(255, 255, 0, 0);
    } else {
      color = const Color.fromARGB(255, 255, 0, 0);
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: const Center(
          child: Text(
            "CF Rating",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      _users[index]['username'],
                      style: TextStyle(
                        color: _colorforRating(_users[index]['rating']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_users[index]['rating'].toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () => _deleteItem(_users[index]['id']),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
