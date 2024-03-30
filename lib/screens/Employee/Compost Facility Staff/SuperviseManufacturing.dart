import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import DateFormat

class SuperviseManufacturing extends StatefulWidget {
  @override
  _SuperviseManufacturingState createState() => _SuperviseManufacturingState();
}

class _SuperviseManufacturingState extends State<SuperviseManufacturing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Manufacturing Supervision'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Bins').snapshots(),
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
            final bins = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bins.length,
              itemBuilder: (context, index) {
                final bin = bins[index];
                final binData = bin.data() as Map<String, dynamic>;
                final filledAtTimestamp = binData['filledAt'] as Timestamp?;
                final completedAtTimestamp = binData['completedAt'] as Timestamp?;

                // Convert Timestamp to formatted date strings
                final filledAt = filledAtTimestamp != null
                    ? DateFormat('yyyy-MM-dd').format(filledAtTimestamp.toDate())
                    : 'Not filled';
                final completedAt = completedAtTimestamp != null
                    ? DateFormat('yyyy-MM-dd').format(completedAtTimestamp.toDate())
                    : 'Not completed';

                return ListTile(
                  title: Text('Bin Name: ${bin.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Quantity: ${binData['maxQuantity']}'),
                      Text('Current Quantity: ${binData['currQuantity']}'),
                      Text('Filled At: $filledAt'),
                      Text('Completed At: $completedAt'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SuperviseManufacturing(),
  ));
}
