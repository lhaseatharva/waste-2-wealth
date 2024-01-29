import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageRequestsPage extends StatefulWidget {
  const ManageRequestsPage({Key? key}) : super(key: key);

  @override
  _ManageRequestsPageState createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  late User? _user;
  late String _currentDay;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _getCurrentDay();
  }

  void _fetchCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _getCurrentDay() {
    final DateTime now = DateTime.now();
    _currentDay = DateFormat('EEEE').format(now);
  }

  Future<List<String>> _fetchRequests() async {
    List<String> requests = [];

    if (_user != null) {
      try {
        // Fetch the user's schedule
        DocumentSnapshot<Map<String, dynamic>> userScheduleDocument =
            await FirebaseFirestore.instance
                .collection('Staff Schedule')
                .doc(_user!.uid)
                .get();

        print('User Schedule Document: ${userScheduleDocument.data()}');

        // Get the selected area for the current day
        String selectedArea =
            userScheduleDocument['schedule']?[_currentDay] ?? '';
        selectedArea = selectedArea; // Ensure it's not null

        print('Selected Area: $selectedArea');

        if (selectedArea.isNotEmpty) {
          // Fetch requests from restaurants in the selected area
          QuerySnapshot<Map<String, dynamic>> requestsSnapshot =
              await FirebaseFirestore.instance
                  .collection('PickupRequests')
                  .where('address', isEqualTo: selectedArea)
                  .get();

          print(
              'Requests Snapshot: ${requestsSnapshot.docs.map((doc) => doc.data())}');

          // Extract request information based on pickupDays
          requests = requestsSnapshot.docs.where((doc) {
            List<String> pickupDays =
                List<String>.from(doc['pickupDays'] ?? []);
            return pickupDays.contains(_currentDay);
          }).map((doc) {
            // Adjust this part based on the actual structure of your documents
            String requestInfo = 'Restaurant: ${doc['restaurantName']}\n'
                'Address: ${doc['address']}\n'
                'Contact Number: ${doc['contactNumber']}\n'
                'Owner: ${doc['ownerName']}';
            return requestInfo;
          }).toList();
        } else {
          print('Selected area is empty.');
        }
      } catch (error) {
        print('Error fetching requests: $error');
      }
    }

    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Manage Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<String>>(
                  future: _fetchRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data!
                            .map((request) => Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      request,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ManageRequestsPage(),
    ),
  );
}
