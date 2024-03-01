import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetSchedulePage extends StatefulWidget {
  const SetSchedulePage({super.key});

  @override
  _SetSchedulePageState createState() => _SetSchedulePageState();
}

class _SetSchedulePageState extends State<SetSchedulePage> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  Map<String, String> selectedLocations = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade300,
        title: const Text('Set Weekly Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (String day in daysOfWeek) ...[
              _buildDayDropdown(day),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade100),
                onPressed: () {
                  _saveSchedule();
                },
                child: const Text('Save Schedule',
                    style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDropdown(String day) {
    return Row(
      children: [
        Text(day),
        const SizedBox(width: 16),
        DropdownButton<String>(
          hint: const Text('Select Location'),
          value: selectedLocations[day],
          onChanged: (String? newValue) {
            setState(() {
              selectedLocations[day] = newValue!;
            });
          },
          items: _buildDropdownItems(),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    // Replace with your list of locations
    List<String> locations = [
      'Kothrud',
      'Wagholi',
      'Viman Nagar',
      'Koregaon Park',
      'Chinchwad',
      'Akurdi',
      'Bibwewadi',
      'Hadapsar',
      'Erandwane',
      'Aundh',
      'Pashan',
      'Warje',
      'Yerawada',
      'Mundhwa',
      'Kondhwa',
      'Ravet',
      'Akurdi',
      'Baner',
      'Balewadi',
      'Wakad'
    ];

    return locations.map((location) {
      return DropdownMenuItem<String>(
        value: location,
        child: Text(location),
      );
    }).toList();
  }

  void _saveSchedule() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Replace 'schedules' with your Firestore collection name
        CollectionReference<Map<String, dynamic>> schedulesCollection =
            FirebaseFirestore.instance.collection('Staff Schedule');

        // Save schedule to Firestore with user's UID as the document ID
        await schedulesCollection.doc(currentUser.uid).set({
          'userId': currentUser.uid,
          'name': currentUser.displayName,
          'schedule': selectedLocations,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Schedule saved successfully'),
        ));

        // Navigate back to the previous page or do any other navigation logic
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error saving schedule: $error');
      // Handle the error (e.g., show an error message to the user)
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: SetSchedulePage(),
    ),
  );
}
