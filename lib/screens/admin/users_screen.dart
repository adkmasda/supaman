import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/dialogs/user_form_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('users').listenable(),
        builder: (context, box, _) {
          final users = box.values.toList();

          if (users.isEmpty) {
            return const Center(
              child: Text('No users added yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final username = user['username'];
              final role = user['role'];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        role == 'admin' ? Colors.blue : Colors.green,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(username),
                  subtitle: Text(
                    role == 'admin' ? 'Administrator' : 'Cashier',
                    style: TextStyle(
                      color: role == 'admin' ? Colors.blue : Colors.green,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUserForm(
                          context,
                          username: username,
                          userData: user,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(context, username, role),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserForm(BuildContext context, {String? username, Map? userData}) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        username: username,
        userData: userData,
      ),
    );
  }

  void _deleteUser(BuildContext context, String username, String role) {
    if (username == '1') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete default admin user')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (role == 'admin') {
                final usersBox = Hive.box('users');
                final adminCount = usersBox.values
                    .where((user) => user['role'] == 'admin')
                    .length;
                if (adminCount <= 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Cannot delete: At least one admin is required'),
                    ),
                  );
                  Navigator.pop(context);
                  return;
                }
              }

              final usersBox = Hive.box('users');
              usersBox.delete(username);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
