import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste2wealth/screens/Buyer/TrackOrder.dart';
import 'package:waste2wealth/screens/Employee/Pickup%20Staff/UpdateProfilePage.dart';
import 'package:waste2wealth/screens/LoginPage.dart';

// Define the GlobalKey for the Drawer
final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({Key? key}) : super(key: key);

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Buyer Home Page'),
      ),
      drawer: Drawer(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightGreen.shade200,
                ),
                child: FutureBuilder<String>(
                  future: _fetchUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final userName = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.account_circle,
                                size: 30, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Track Orders'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrackOrder()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Update Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfilePage(
                        currentUser: FirebaseAuth.instance.currentUser,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Log Out'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Buyer!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade100,
                foregroundColor: Colors.black,
              ),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _fetchUserName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final userData = userSnapshot.data() as Map<String, dynamic>;
    final userName = userData['name'];
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    return '$userName, $userEmail';
  }
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCompostType;
  double? compostRate;
  double totalBill = 0.0;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<String> compostTypes = ['Vermicompost', 'Organic Compost'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Order'),
        backgroundColor: Colors.lightGreen.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCompostType,
                onChanged: (value) {
                  setState(() {
                    selectedCompostType = value!;
                    fetchCompostRate(selectedCompostType!);
                  });
                },
                items: compostTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Type of Compost',
                ),
              ),
              if (compostRate != null)
                Text('Rate: $compostRate'), // Display compost rate
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
                onChanged: (_) => calculateTotalBill(),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Total Bill: $totalBill'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Place order
                    placeOrder();
                  }
                },
                child: Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchCompostRate(String type) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Compost Stock')
          .doc(type)
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        compostRate = data['rate'];
      });
      calculateTotalBill();
    } catch (error) {
      print('Error fetching compost rate: $error');
    }
  }

  void calculateTotalBill() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (compostRate != null) {
      setState(() {
        totalBill = quantity * compostRate!;
      });
    }
  }

  Future<void> placeOrder() async {
    try {
      final double quantity = double.parse(_quantityController.text);
      final String address = _addressController.text;

      // Add order to Firestore
      await FirebaseFirestore.instance.collection('Orders').add({
        'compostType': selectedCompostType,
        'quantity': quantity,
        'address': address,
        'totalBill': totalBill,
        'paymentMethod': 'Cash/UPI at Delivery',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully'),
        ),
      );

      // Clear form fields
      _quantityController.clear();
      _addressController.clear();
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $error'),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: BuyerHomePage(),
  ));
}
