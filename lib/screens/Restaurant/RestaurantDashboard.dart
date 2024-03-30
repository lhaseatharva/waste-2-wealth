import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/screens/Employee/Pickup%20Staff/ManagePickupSchedule.dart';
import 'package:waste2wealth/screens/LoginPage.dart';
import 'package:waste2wealth/screens/Restaurant/UpdateProfilePage.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({Key? key});

  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  late User? _currentUser;
  int totalRequests = 5; // Initialize with actual data
  int pendingRequests = 4; // Initialize with actual data

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    await _currentUser?.reload(); // Refresh user data to get the updated display name
    setState(() {});
  }

  Future<String> _fetchRestaurantName() async {
    final userId = _currentUser?.uid;
    final userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userSnapshot.exists ? userSnapshot['restaurantName'] : 'Restaurant Name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Restaurant Dashboard'),
      ),
      drawer: Drawer(
        child: FutureBuilder<String>(
          future: _fetchRestaurantName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Display a loading indicator while fetching data
            } else {
              final restaurantName = snapshot.data ?? 'Restaurant Name';
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade200,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.restaurant, size: 30, color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Text(
                          restaurantName,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _currentUser?.email ?? 'Email@example.com',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Update Details'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfilePage(currentUser: _currentUser)));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Update Schedule'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePickupSchedule()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Log Out'),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to the Restaurant Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Total Orders', totalRequests.toString()),
                        _buildStatCard('Pending Orders', pendingRequests.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: RestaurantDashboard(),
    ),
  );
}
