import 'package:flutter/material.dart';
import 'package:waste2wealth/screens/LoginPage.dart';
import 'package:waste2wealth/screens/RequestPickupPage.dart';
import 'RegistrationPage.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/homeLogo.png', width: 200, height: 250),
            const Center(
              child: Text('  Welcome to\nwaste2wealth',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                minimumSize: const Size(
                    double.infinity, 50), // Set minimum width and height
              ),
              onPressed: () {
                _navigateToReqPage(context);
              },
              child: const Text('Request Pickup',
                  style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                minimumSize: const Size(
                    double.infinity, 50), // Set minimum width and height
              ),
              onPressed: () {
                _navigateToLogPage(context);
              },
              child: const Text('Login', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                minimumSize: const Size(
                    double.infinity, 50), // Set minimum width and height
              ),
              onPressed: () {
                _navigateToRegPage(context);
              },
              child:
                  const Text('Register', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRegPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegistrationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var curveTween = CurveTween(curve: curve);
          var tween = Tween(begin: begin, end: end).chain(curveTween);
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
  void _navigateToLogPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var curveTween = CurveTween(curve: curve);
          var tween = Tween(begin: begin, end: end).chain(curveTween);
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
  void _navigateToReqPage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RequestPickupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var curveTween = CurveTween(curve: curve);
          var tween = Tween(begin: begin, end: end).chain(curveTween);
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
