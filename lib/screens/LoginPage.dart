import 'package:flutter/material.dart';
import 'package:waste2wealth/screens/Buyer/BuyerHomePage.dart';
import 'package:waste2wealth/screens/Employee/Compost Facility Staff/CompostFacilityStaffHomePage.dart';
import 'package:waste2wealth/screens/Employee/Pickup Staff/PickupStaffHomePage.dart';
import 'package:waste2wealth/screens/RegistrationPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'Employee';
  String selectedSubRole = 'Pickup Staff';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Login Page', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/homeLogo.png',
                  width: 200,
                  height: 250,
                ),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                          // Reset the subRole when the role changes
                          selectedSubRole = 'Pickup Staff';
                        });
                      },
                      items: ['Employee', 'Buyer', 'Restaurant'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Visibility(
                      visible: selectedRole == 'Employee',
                      child: DropdownButtonFormField<String>(
                        value: selectedSubRole,
                        onChanged: (value) {
                          setState(() {
                            selectedSubRole = value!;
                          });
                        },
                        items: ['Pickup Staff', 'Compost Facility Staff']
                            .map((subRole) {
                          return DropdownMenuItem(
                            value: subRole,
                            child: Text(subRole),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'SubRole',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            UserCredential userCredential =
                                await _auth.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            String role = selectedRole;
                            String subRole = selectedSubRole;

                            if (role == 'Employee') {
                              List<String> roleEmails =
                                  await fetchRoleEmails(role, subRole);

                              if (roleEmails
                                  .contains(userCredential.user?.email ?? "")) {
                                if (subRole == 'Pickup Staff') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PickupStaffHomePage()),
                                  );
                                } else if (subRole ==
                                    'Compost Facility Staff') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CompostFacilityStaffHomePage()),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid email or password'),
                                  ),
                                );
                              }
                            } else if (role == 'Buyer') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BuyerHomePage()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'You are now logged in successfully'),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            print("Firebase Auth Error: ${e.message}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.message}"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Login',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, animatio, secondaryAnimation) => const RegistrationPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0,0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutQuad;
                                var tween = Tween(begin: begin,end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation=animation.drive(tween);
                                return SlideTransition(position: offsetAnimation, child: child,);
                              },),
                        );
                      },
                      child: const Text('New User? Register Here',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> fetchRoleEmails(String role, String subRole) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Users').get();

      List<String> emails = [];
      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        String userRole = userData['role'] ?? '';
        String userSubRole = userData['subRole'] ?? '';
        String userEmail = userData['email'] ?? '';

        if (userRole == role && userSubRole == subRole) {
          emails.add(userEmail);
        }
      });
      return emails;
    } catch (e) {
      print("Error fetching role emails: $e");
    }
    return [];
  }
}
