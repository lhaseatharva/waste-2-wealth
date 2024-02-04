import 'package:flutter/material.dart';
import 'package:waste2wealth/Provider/registration_provider.dart';
import 'package:waste2wealth/screens/LoginPage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    home: RegistrationPage(),
  ));
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final List<String> roles = ['Employee', 'Buyer', 'Restaurant Owner'];
  final List<String> employeeSubRoles = [
    'Pickup Staff',
    'Compost Facility Staff'
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    Future<void> registerUser() async {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'contactNumber': _contactNumberController.text,
          'role': provider.selectedRole,
          'subRole': provider.selectedSubRole,
        });
        print("User registered: ${userCredential.user!.uid}");
        provider.setRegistrationSuccessful(true);
      } on FirebaseAuthException catch (e) {
        print("Error during registration: ${e.message}");
        provider.setRegistrationSuccessful(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed: ${e.message}'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text(
          'Registration Page',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
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
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        } else if (RegExp(r'\d').hasMatch(value)) {
                          return 'Name should not contain numeric values';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Enter Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 8) {
                          return 'Password should be at least 8 characters';
                        } else if (!RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$')
                            .hasMatch(value)) {
                          return 'Password should contain at least one uppercase letter, one lowercase letter, and one number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Invalid contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: provider.selectedRole,
                      onChanged: (value) {
                        provider.setSelectedRole(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                      items: roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                    ),
                    if (provider.selectedRole == 'Employee') ...[
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        key: ValueKey(provider.selectedRole),
                        value: provider.selectedSubRole,
                        onChanged: (value) {
                          provider.setSelectedSubRole(value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sub-role',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a sub-role';
                          }
                          return null;
                        },
                        items: employeeSubRoles.map((subRole) {
                          return DropdownMenuItem<String>(
                            value: subRole,
                            child: Text(subRole),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (provider.selectedRole == 'Employee' &&
                            provider.selectedSubRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select your Sub-role')));
                        }

                        if (_formKey.currentState!.validate()) {
                          await registerUser(); // Call the registration function

                          if (provider.registrationSuccessful) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration Successful!'),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade100,
                      ),
                      child: const Text('Register',
                          style: TextStyle(color: Colors.black)),
                    ),
                    if (provider.registrationSuccessful) ...[
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen.shade100,
                        ),
                        child: const Text('Go to Login',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
