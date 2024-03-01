import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/RequestNotifierProvider.dart';
import 'package:waste2wealth/screens/Restaurant/RestauaranLocationtMap.dart';

class ManageRequestsPage extends StatefulWidget {
  const ManageRequestsPage({Key? key}) : super(key: key);

  @override
  _ManageRequestsPageState createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  late User? _user;
  late String _currentDay;
  bool _loading = false;

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

  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    List<Map<String, dynamic>> requests = [];

    if (_user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userScheduleDocument =
            await FirebaseFirestore.instance
                .collection('Staff Schedule')
                .doc(_user!.uid)
                .get();

        String selectedArea =
            userScheduleDocument['schedule']?[_currentDay] ?? '';

        if (selectedArea.isNotEmpty) {
          QuerySnapshot<Map<String, dynamic>> requestsSnapshot =
              await FirebaseFirestore.instance
                  .collection('PickupRequests')
                  .where('address', isEqualTo: selectedArea)
                  .get();

          requests = requestsSnapshot.docs.where((doc) {
            List<String> pickupDays =
                List<String>.from(doc['pickupDays'] ?? []);
            String status = doc[_currentDay.toLowerCase() + 'Status'];

            return pickupDays.contains(_currentDay) && status == 'pending';
          }).map((doc) {
            return {
              'id': doc.id,
              'restaurantName': doc['restaurantName'],
              'address': doc['address'],
              'contactNumber': doc['contactNumber'],
              'ownerName': doc['ownerName'],
              'latitude': doc['latitude'],
              'longitude': doc['longitude'],
            };
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

  Future<void> _markRequestAsComplete(
      BuildContext context, String requestId) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content:
              const Text('Are you sure you want to mark this request as complete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        setState(() {
          _loading = true;
        });

        await FirebaseFirestore.instance
            .collection('PickupRequests')
            .doc(requestId)
            .update({
          '${_currentDay.toLowerCase()}Status': 'complete',
          '${_currentDay.toLowerCase()}CompletionTimestamp':
              FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request marked as complete'),
          ),
        );

        final updatedRequests = await _fetchRequests();
        Provider.of<RequestNotifierProvider>(context, listen: false)
            .updateRequests(updatedRequests);

      } catch (error) {
        print('Error marking request as complete: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking request as complete'),
          ),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Function to initiate a phone call
  Future<void> _callRestaurant(String phoneNumber) async {
    final Uri dialNumber = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launch(dialNumber.toString()); // Launch the phone call
    } catch (e) {
      print(
          'Could not launch phone call: $e'); // Handle error if unable to launch
    }
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
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchRequests(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final request = snapshot.data![index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Restaurant: ${request['restaurantName']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Address: ${request['address']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Contact Number: ${request['contactNumber']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Owner: ${request['ownerName']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.location_pin,
                                              color: Colors.black),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.lightGreen.shade100,
                                            fixedSize:
                                                const Size.fromWidth(500),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    RestaurantLocationMapPage(
                                                  latitude: request['latitude'],
                                                  longitude: request['longitude'],
                                                  restaurantName:
                                                      request['restaurantName'],
                                                ),
                                              ),
                                            );
                                          },
                                          label: const Text(
                                            'Navigate',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.phone,
                                              color: Colors.black),
                                          onPressed: () {
                                            _callRestaurant(request[
                                                'contactNumber']); // Pass the phone number
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.lightGreen.shade100,
                                            fixedSize:
                                                const Size.fromWidth(500),
                                          ),
                                          label: const Text(
                                            'Call Restaurant',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.task_alt_outlined,
                                              color: Colors.black),
                                          onPressed: () {
                                            _markRequestAsComplete(
                                                context, request['id']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.lightGreen.shade100,
                                            fixedSize:
                                                const Size.fromWidth(500),
                                          ),
                                          label: const Text(
                                            'Mark as Complete',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
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
    ChangeNotifierProvider(
      create: (context) => RequestNotifierProvider(),
      child: MaterialApp(
        home: ManageRequestsPage(),
      ),
    ),
  );
}
