import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/UserProfileModel.dart';

class UpdateProfilePage extends StatefulWidget {
  final User? currentUser;

  const UpdateProfilePage({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _savingChanges = false;

  @override
  void initState() {
    super.initState();

    
    _nameController.text = widget.currentUser?.displayName ?? '';
    _emailController.text = widget.currentUser?.email ?? '';

    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      if (widget.currentUser != null) {
        await widget.currentUser?.reload();

        DocumentSnapshot<Map<String, dynamic>> userDocument =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.currentUser?.uid)
                .get();

        _nameController.text = userDocument['name'] ?? '';
        _emailController.text = widget.currentUser?.email ?? '';
        _mobileController.text = userDocument['contactNumber'] ?? '';
      }
    } catch (error) {
      print("Error fetching user details: $error");
    }
  }

  Future<void> _saveChanges(BuildContext context) async {
    try {
      setState(() {
        _savingChanges = true;
      });

      await widget.currentUser?.updateDisplayName(_nameController.text);
      await widget.currentUser?.updateEmail(_emailController.text);

      if (widget.currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.currentUser?.uid)
            .update({
          'contactNumber': _mobileController.text,
          'name': _nameController.text,
          'email': _emailController.text,
        });

        Provider.of<UserProfileModel>(context, listen: false).updateUserProfile(
          newName: _nameController.text,
          newEmail: _emailController.text,
          newContactNumber: _mobileController.text,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details saved successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      print("Error updating profile: $error");
    } finally {
      setState(() {
        _savingChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Update Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.email, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_savingChanges) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
