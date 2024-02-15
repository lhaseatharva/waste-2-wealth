import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/pickuprequest_provider.dart';
import 'package:geolocator/geolocator.dart';

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

  // Replace with your Firestore collection reference
  final CollectionReference pickupRequestsRef =
      FirebaseFirestore.instance.collection('PickupRequests');

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
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                provider.setLoading(true);
                                LocationPermission permission =
                                    await Geolocator.checkPermission();
                                if (permission == LocationPermission.denied ||
                                    permission == LocationPermission.deniedForever) {
                                  // Handle denied permission
                                  print('Location permission denied');
                                  LocationPermission ask =
                                      await Geolocator.requestPermission();
                                } else {
                                  Position? location = await _captureLocation();
                                  if (location != null) {
                                    await saveRequestToFirestore(context, location);
                                  }
                                }
                              }
                            },
                      child: provider.isLoading
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
                      onPressed: () async {
                        LocationPermission permission =
                            await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          // Handle denied permission
                          print('Location permission denied');
                          LocationPermission ask =
                              await Geolocator.requestPermission();
                        } else {
                          Position? location = await _captureLocation();
                          if (location != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Location captured successfully!!'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                          style: TextStyle(color: Colors.black),
                          'Grab current Location'),
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

  Future<void> saveRequestToFirestore(
      BuildContext context, Position location) async {
    final provider = Provider.of<PickupRequestProvider>(context, listen: false);

    try {
      // Capture current timestamp
      final timestamp = FieldValue.serverTimestamp();

      // Save request data to Firestore
      final newDocumentRef = await pickupRequestsRef.add({
        'restaurantName': _restaurantNameController.text,
        'ownerName': _ownerNameController.text,
        'contactNumber': _contactNumberController.text,
        'address': _addressController.text,
        'pickupDays': _pickupDays,
        'timestamp': timestamp,
        'latitude': location.latitude,
        'longitude': location.longitude,
      });

      provider.setLoading(false);

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
      provider.setLoading(false);
      if (kDebugMode) {
        print('Error saving request to Firestore: $e');
      }
      // Handle the error as needed
    }
  }

  Future<Position?> _captureLocation() async {
    try {
      // Request permission to access device's location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle denied permission
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