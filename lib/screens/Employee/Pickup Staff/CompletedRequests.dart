import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/CompletedRequestsProvider.dart';
import 'package:waste2wealth/screens/Employee/Pickup%20Staff/CompFacilityNav.dart';

class CompletedRequestsPage extends StatefulWidget {
  const CompletedRequestsPage({Key? key}) : super(key: key);

  @override
  _CompletedRequestsPageState createState() => _CompletedRequestsPageState();
}

class _CompletedRequestsPageState extends State<CompletedRequestsPage> {
  late List<Map<String, dynamic>> completedRequests = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedRequests(context); 
  }

  Future<void> fetchCompletedRequests(BuildContext context) async {
    try {
      final DateTime now = DateTime.now();
      final String currentDay = DateFormat('EEEE').format(now);

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('PickupRequests')
              .where('${currentDay.toLowerCase()}Status', isEqualTo: 'complete')
              .get();

      setState(() {
        completedRequests = snapshot.docs.map((doc) => doc.data()).toList();
      });

      
      Provider.of<CompletedRequestsProvider>(context, listen: false)
          .setLoading(false);
    } catch (error) {
      print('Error fetching completed requests: $error');
      
      Provider.of<CompletedRequestsProvider>(context, listen: false)
          .setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Requests'),
        backgroundColor: Colors.lightGreen.shade200,
      ),
      body: Consumer<CompletedRequestsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return completedRequests.isEmpty
                ? Center(
                    child: Text('No completed requests for today'),
                  )
                : ListView.builder(
                    itemCount: completedRequests.length,
                    itemBuilder: (context, index) {
                      final request = completedRequests[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const CompFacilityNav()));
        },
        label: const Text('Navigate to Compost Facility'),
        icon: const Icon(Icons.navigation),
      ),
    );
  }
}
