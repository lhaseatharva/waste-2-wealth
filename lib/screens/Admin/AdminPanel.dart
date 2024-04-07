import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/screens/LoginPage.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.lightGreen.shade200,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCollectionCount('Pickup Requests', 'PickupRequests'),
            _buildCollectionCount('Restaurants', 'Restaurants'),
            _buildCollectionCount('Bins', 'Bins'),
            _buildCollectionCount('Compost Stock', 'CompostStock'),
            _buildCollectionCount('Waste Stock', 'WasteStock'),
            _buildCollectionCount('Orders', 'Orders'),
            _buildCollectionCount('Users', 'Users'),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCount(String title, String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final count = snapshot.data!.size;
          return ListTile(
            title: Text('$title: $count'),
          );
        }
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminPanel(),
  ));
}
