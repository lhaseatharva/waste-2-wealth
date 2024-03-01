import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waste2wealth/Provider/LoginLogoutProvider.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/screens/Employee/Compost%20Facility%20Staff/AllocateBin.dart';
import 'package:waste2wealth/screens/Employee/Compost%20Facility%20Staff/SuperviseManufacturing.dart';
import 'package:waste2wealth/screens/Employee/Compost%20Facility%20Staff/UpdateCompostStock.dart';
import 'package:waste2wealth/screens/Employee/Compost%20Facility%20Staff/UpdateWasteStock.dart';
import 'package:waste2wealth/screens/Employee/Pickup%20Staff/UpdateProfilePage.dart';
import 'package:waste2wealth/screens/LoginPage.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const CompostFacilityStaffHomePage(),
    ),
  );
}

class CompostFacilityStaffHomePage extends StatefulWidget {
  const CompostFacilityStaffHomePage({Key? key}) : super(key: key);

  @override
  _CompostFacilityStaffHomePageState createState() => _CompostFacilityStaffHomePageState();
}

class _CompostFacilityStaffHomePageState extends State<CompostFacilityStaffHomePage> {
  late User? currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<DrawerWidgetState> _drawerKey = GlobalKey<DrawerWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Compost Facility Staff Home'),
      ),
      drawer: DrawerWidget(key: _drawerKey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              currentUser = snapshot.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome ${currentUser?.displayName ?? ''}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.update_rounded,
                          label: 'Weigh & Update Waste Stock',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateWasteStock()),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.add_circle_rounded,
                          label: 'Allocate Bins',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AllocateBin()),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.supervisor_account_rounded,
                          label: 'Supervise Compost Manufacturing',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SuperviseManufacturing()),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.update_rounded,
                          label: 'Update Compost Stock',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateCompostStock()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  DrawerWidgetState createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  late User? currentUser;

  void updateDrawer() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginLogoutProvider>(context, listen: false);
    return Drawer(
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            currentUser = snapshot.data;
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
                        currentUser?.displayName ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        currentUser?.email ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Update Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProfilePage(currentUser: currentUser),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Log Out'),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Drawer();
          }
        },
      ),
    );
  }
}
