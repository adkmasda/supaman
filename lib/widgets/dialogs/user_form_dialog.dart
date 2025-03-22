import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserFormDialog extends StatefulWidget {
  final String? username;
  final Map? userData;

  const UserFormDialog({
    super.key,
    this.username,
    this.userData,
  });

  @override
  UserFormDialogState createState() => UserFormDialogState();
}

class UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'cashier';

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _usernameController.text = widget.username!;
      _selectedRole = widget.userData!['role'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.userData == null ? 'Add User' : 'Edit User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              enabled: widget.userData == null, // Only enabled for new users
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: widget.userData == null
                    ? 'Password'
                    : 'New Password (leave empty to keep current)',
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (widget.userData == null &&
                    (value == null || value.isEmpty)) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'cashier',
                  child: Text('Cashier'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveUser,
          child: Text(widget.userData == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final usersBox = Hive.box('users');

      // Check if changing from admin to cashier
      if (widget.userData != null &&
          widget.userData!['role'] == 'admin' &&
          _selectedRole == 'cashier') {
        final adminCount =
            usersBox.values.where((user) => user['role'] == 'admin').length;
        if (adminCount <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Cannot change role: At least one admin is required'),
            ),
          );
          return;
        }
      }

      // For new user
      if (widget.userData == null) {
        if (usersBox.get(_usernameController.text) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already exists')),
          );
          return;
        }

        usersBox.put(_usernameController.text, {
          'username': _usernameController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
        });
      }
      // For existing user
      else {
        usersBox.put(widget.username, {
          'username': widget.username,
          'password': _passwordController.text.isEmpty
              ? widget.userData!['password']
              : _passwordController.text,
          'role': _selectedRole,
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
