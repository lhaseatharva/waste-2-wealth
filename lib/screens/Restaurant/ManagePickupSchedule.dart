import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagePickupSchedule extends StatefulWidget {
  @override
  _ManagePickupScheduleState createState() => _ManagePickupScheduleState();
}

class _ManagePickupScheduleState extends State<ManagePickupSchedule> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserUid = '';
  String _restaurantName = '';
  Map<String, String> _pickupStatus = {
    'Monday': 'No',
    'Tuesday': 'No',
    'Wednesday': 'No',
    'Thursday': 'No',
    'Friday': 'No',
    'Saturday': 'No',
    'Sunday': 'No',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentUserUid();
  }

  void _getCurrentUserUid() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserUid = user.uid;
      });
      _fetchRestaurantName();
      _fetchPickupStatus();
    }
  }

  void _fetchRestaurantName() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(_currentUserUid).get();
      if (userDoc.exists) {
        setState(() {
          _restaurantName = userDoc.get('restaurantName') as String? ?? '';
        });
      }
    } catch (e) {
      print('Error fetching restaurant name: $e');
    }
  }

  void _fetchPickupStatus() async {
    try {
      DocumentSnapshot pickupDoc = await _firestore
          .collection('PickupRequests')
          .doc(_currentUserUid)
          .get();
      if (pickupDoc.exists) {
        Map<String, dynamic> data =
            pickupDoc.data() as Map<String, dynamic>;
        data.forEach((key, value) {
          if (_pickupStatus.containsKey(key)) {
            setState(() {
              _pickupStatus[key] = value == 'pending' ? 'Yes' : 'No';
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching pickup status: $e');
    }
  }

  void _updateTempPickupStatus(String day, String status) {
    setState(() {
      _pickupStatus[day] = status;
    });
  }

  void _saveChanges() async {
    try {
      WriteBatch batch = _firestore.batch();

      _pickupStatus.forEach((day, status) {
        String newStatus = status == 'Yes' ? 'pending' : 'not selected';
        batch.update(
          _firestore.collection('PickupRequests').doc(_currentUserUid),
          {'${day.toLowerCase()}Status': newStatus},
        );
      });

      await batch.commit();
    } catch (e) {
      print('Error saving changes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Manage Pickup Schedule'),
        actions: [
          IconButton(
            onPressed: _saveChanges,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _restaurantName.isNotEmpty
          ? ListView(
              children: _pickupStatus.keys.map((day) {
                return ListTile(
                  title: Text(day),
                  trailing: DropdownButton<String>(
                    value: _pickupStatus[day],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateTempPickupStatus(day, newValue);
                      }
                    },
                    items: <String>['Yes', 'No']
                        .map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    )
                        .toList(),
                  ),
                );
              }).toList(),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ManagePickupSchedule(),
  ));
}
