import 'package:flutter/material.dart';

class CompostFacilityStaffHomePage extends StatefulWidget {
  const CompostFacilityStaffHomePage({super.key});

  @override
  State<CompostFacilityStaffHomePage> createState() => _CompostFacilityStaffHomePage();
}

class _CompostFacilityStaffHomePage extends State<CompostFacilityStaffHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Compost Facility Staff Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Compost Facility Staff!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add functionality for Pickup Staff tasks
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade100,
                foregroundColor: Colors.black,
              ),
              child: const Text('Allocate Bins'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add functionality for other tasks or features
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.lightGreen.shade100,
              ),
              child: const Text('Check Status'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: CompostFacilityStaffHomePage(),
    ),
  );
}
