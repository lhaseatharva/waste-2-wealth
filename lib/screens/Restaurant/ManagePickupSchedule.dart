import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagePickupSchedule extends StatefulWidget {
  const ManagePickupSchedule({Key? key}) : super(key: key);

  @override
  _ManagePickupScheduleState createState() => _ManagePickupScheduleState();
}

class _ManagePickupScheduleState extends State<ManagePickupSchedule> {
  late Map<String, bool> schedule = {};

  @override
  void initState() {
    super.initState();
    fetchUserSchedule();
  }

  Future<void> fetchUserSchedule() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userContactNumber = await _fetchUserContactNumber(currentUser.uid);

      // Initialize all days to false by default
      schedule = {
        'Monday': false,
        'Tuesday': false,
        'Wednesday': false,
        'Thursday': false,
        'Friday': false,
        'Saturday': false,
        'Sunday': false,
      };

      // Fetch data from Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('PickupRequests')
          .where('contactNumber', isEqualTo: userContactNumber)
          .get();

      // Iterate through documents to update schedule
      snapshot.docs.forEach((doc) {
        // Check for fields like tuesdayStatus, mondayStatus, etc.
        if (doc['tuesdayStatus'] != null && doc['tuesdayStatus']) {
          schedule['Tuesday'] = true;
        }
        if (doc['mondayStatus'] != null && doc['mondayStatus']) {
          schedule['Monday'] = true;
        }
        if (doc['wednesdayStatus'] != null && doc['wednesdayStatus']) {
          schedule['Wednesday'] = true;
        }
        if (doc['thursdayStatus'] != null && doc['thursdayStatus']) {
          schedule['Thursday'] = true;
        }
        if (doc['fridayStatus'] != null && doc['fridayStatus']) {
          schedule['Friday'] = true;
        }
        if (doc['saturdayStatus'] != null && doc['saturdayStatus']) {
          schedule['Saturday'] = true;
        }
        if (doc['sundayStatus'] != null && doc['sundayStatus']) {
          schedule['Sunday'] = true;
        }
        // Add conditions for other days similarly
      });

      setState(() {});
    }
  }

  Future<String> _fetchUserContactNumber(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();
    return userDoc['contactNumber'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Pickup Schedule'),
        backgroundColor: Colors.lightGreen.shade200,
      ),
      body: schedule.isNotEmpty
          ? ListView(
              children: schedule.entries.map((entry) {
                final day = entry.key;
                final status = entry.value;
                return ListTile(
                  title: Text(day),
                  subtitle: DropdownButtonFormField<bool>(
                    value: status,
                    items: [
                      DropdownMenuItem(value: true, child: Text('Yes')),
                      DropdownMenuItem(value: false, child: Text('No')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        schedule[day] = value!;
                      });
                    },
                  ),
                );
              }).toList(),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveUserSchedule();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void saveUserSchedule() {
    // Implement your saving logic here
    // For demonstration purposes, just print the schedule
    print(schedule);
  }
}

void main() {
  runApp(MaterialApp(
    home: ManagePickupSchedule(),
  ));
}
