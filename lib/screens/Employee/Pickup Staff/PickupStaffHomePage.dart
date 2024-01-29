import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/screens/Employee/Pickup%20Staff/UpdateProfilePage.dart';

class PickupStaffHomePage extends StatefulWidget {
  const PickupStaffHomePage({Key? key}) : super(key: key);

  @override
  State<PickupStaffHomePage> createState() => _PickupStaffHomePageState();
}

class _PickupStaffHomePageState extends State<PickupStaffHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Pickup Staff Home'),
      ),
      drawer: Drawer(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              User? user = snapshot.data;

              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade200,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 30, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.displayName ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('Update Schedule'),
                    onTap: () {
                      // Add functionality for updating schedule
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Update Profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfilePage(currentUser: user),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Log Out'),
                    onTap: () {
                      // Add functionality for logging out
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                ],
              );
            } else {
              // Show loading indicator or handle other states
              return const Drawer();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Pickup Staff!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ActionCard(
                icon: Icons.calendar_today,
                label: 'Set Weekly Schedule',
                onPressed: () {
                  // Add functionality for setting weekly schedule
                },
              ),
              const SizedBox(height: 16),
              ActionCard(
                icon: Icons.assignment,
                label: 'Manage Requests',
                onPressed: () {
                  // Add functionality for managing requests
                },
              ),
              const SizedBox(height: 16),
              ActionCard(
                icon: Icons.delivery_dining,
                label: 'Manage Delivery',
                onPressed: () {
                  // Add functionality for managing delivery
                  // Show fulfilled requests with Maps location link
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: PickupStaffHomePage(),
    ),
  );
}
