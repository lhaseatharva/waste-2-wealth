import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/pickuprequest_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestPickupPage extends StatefulWidget {
  const RequestPickupPage({Key? key}) : super(key: key);

  @override
  _RequestPickupPageState createState() => _RequestPickupPageState();
}

class _RequestPickupPageState extends State<RequestPickupPage> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final List<String> _pickupDays = [];

  final CollectionReference pickupRequestsRef =
      FirebaseFirestore.instance.collection('PickupRequests');

  bool _isSubmitLoading = false;
  bool _isLocationLoading = false;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PickupRequestProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightGreen.shade200,
            title: const Text(
              'Request Pickup Page',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _restaurantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Restaurant Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the restaurant name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Manager/Owner Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the manager/owner name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _contactNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the contact number';
                        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Invalid contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Select Pickup Days:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var day in [
                            'Sunday',
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                          ])
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_pickupDays.contains(day)) {
                                    _pickupDays.remove(day);
                                  } else {
                                    _pickupDays.add(day);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pickupDays.contains(day)
                                    ? Colors.deepPurple.shade100
                                    : null,
                              ),
                              child: Text(day),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade100,
                      ),
                      onPressed: _isSubmitLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isSubmitLoading = true;
                                });
                                await _handleFormSubmission(context);
                                setState(() {
                                  _isSubmitLoading = false;
                                });
                              }
                            },
                      child: _isSubmitLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Submit Request',
                              style: TextStyle(color: Colors.black),
                            ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen.shade100),
                      onPressed: _isLocationLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLocationLoading = true;
                              });
                              await _captureCurrentLocation(context);
                              setState(() {
                                _isLocationLoading = false;
                              });
                            },
                      child: _isLocationLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Grab current Location',
                              style: TextStyle(color: Colors.black),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFormSubmission(BuildContext context) async {
    final provider = Provider.of<PickupRequestProvider>(
      context,
      listen: false,
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied');
        LocationPermission ask = await Geolocator.requestPermission();
      } else {
        Position? location = await _captureLocation();
        if (location != null) {
          await _saveRequestToFirestore(context, location);
        }
      }
    } catch (e) {
      provider.setLoading(false);
      if (kDebugMode) {
        print('Error saving request to Firestore: $e');
      }
      // Handle the error as needed
    }
  }

  Future<void> _captureCurrentLocation(BuildContext context) async {
    final provider = Provider.of<PickupRequestProvider>(
      context,
      listen: false,
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied');
        LocationPermission ask = await Geolocator.requestPermission();
      } else {
        Position? location = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (location != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location captured successfully!!'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error capturing location: $e');
    }
  }

  Future<void> _saveRequestToFirestore(
    BuildContext context,
    Position location,
  ) async {
    final provider = Provider.of<PickupRequestProvider>(
      context,
      listen: false,
    );

    try {
      // Generate an alphanumeric request ID
      final requestId =
          'REQ${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(10000)}';

      // Capture current timestamp
      final timestamp = FieldValue.serverTimestamp();

      // Save request data to Firestore with user's UID as document ID
      Map<String, dynamic> requestData = {
        'requestId': requestId,
        'restaurantName': _restaurantNameController.text,
        'ownerName': _ownerNameController.text,
        'contactNumber': _contactNumberController.text,
        'address': _addressController.text,
        'pickupDays': _pickupDays,
        'timestamp': timestamp,
        'latitude': location.latitude,
        'longitude': location.longitude,
      };

      // Create separate boolean fields for each day and set status
      final allDays = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];

      // Initialize status for all days
      for (var day in allDays) {
        requestData['${day.toLowerCase()}Status'] =
            _pickupDays.contains(day) ? 'pending' : 'not selected';
      }

      // Save request data with user's UID as document ID
      await pickupRequestsRef
          .doc(currentUser
              ?.uid) // Use user's UID as document ID if currentUser is not null
          .set(requestData);

      // Display confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Submitted Successfully!!'),
          content: const Text('Your pickups will start as per your schedule'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add any additional actions after submission
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving request to Firestore: $e');
      }
      // Handle the error as needed
    }
  }

  Future<Position?> _captureLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location permission denied');
        LocationPermission ask = await Geolocator.requestPermission();
      } else {
        return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      }
    } catch (e) {
      print('Error capturing location: $e');
    }
    return null;
  }
}
