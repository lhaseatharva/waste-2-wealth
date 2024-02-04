import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/LoginLogoutProvider.dart';
import 'package:waste2wealth/screens/LoginPage.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  int totalOrders = 50;
  int pendingOrders = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Restaurant Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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
                    'Restaurant Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Email@example.com',
                    style: TextStyle(
                      color: Colors.white,
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
                // Navigate to the update details page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Update Schedule'),
              onTap: () {
                // Navigate to the update schedule page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                Provider.of<LoginLogoutProvider>(context, listen: false).logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginPage()));
              },
            ),
          ],
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
                        _buildStatCard('Total Orders', totalOrders.toString()),
                        _buildStatCard('Pending Orders', pendingOrders.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your action when the button is pressed
              },
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
      home: RestaurantDashboard(),
    ),
  );
}