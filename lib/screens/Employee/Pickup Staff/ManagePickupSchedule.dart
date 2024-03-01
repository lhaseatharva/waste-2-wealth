import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagePickupSchedule extends StatefulWidget {
  const ManagePickupSchedule({Key? key}) : super(key: key);

  @override
  _ManagePickupScheduleState createState() => _ManagePickupScheduleState();
}

class _ManagePickupScheduleState extends State<ManagePickupSchedule> {
  late Map<String, dynamic> schedule = {};
  late String currentUserUid;

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

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
  }

  Future<void> getCurrentUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserUid = user!.uid;
    });
    fetchUserSchedule(currentUserUid);
  }

  Future<void> fetchUserSchedule(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Staff Schedule')
              .doc(uid)
              .get();

      setState(() {
        schedule = Map<String, dynamic>.from(snapshot.data()?['schedule'] ?? {});
      });
    } catch (error) {
      print('Error fetching user schedule: $error');
    }
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
              children: schedule.keys.map((day) {
                return ListTile(
                  title: Text(day),
                  subtitle: DropdownButtonFormField<String>(
                    value: schedule[day] ?? locations[0],
                    items: locations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        schedule[day] = value;
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

  Future<void> saveUserSchedule() async {
    try {
      await FirebaseFirestore.instance
          .collection('Staff Schedule')
          .doc(currentUserUid)
          .update({'schedule': schedule});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated Schedule saved successfully'),
        ),
      );
    } catch (error) {
      print('Error saving user schedule: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving schedule'),
        ),
      );
    }
  }
}
