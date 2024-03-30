import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackOrder extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  late final String currentUserUid;

  @override
  void initState() {
    super.initState();
    // Fetch current user's UID
    getCurrentUserUid();
  }

  Future<void> getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserUid = user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Orders'),
        backgroundColor: Colors.lightGreen.shade200,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final orders = snapshot.data!.docs;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final compostType = order['compostType'];
                final quantity = order['quantity'];
                final address = order['address'];
                final totalBill = order['totalBill'];
                final paymentMethod = order['paymentMethod'];

                return ListTile(
                  title: Text('Compost Type: $compostType'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: $quantity'),
                      Text('Address: $address'),
                      Text('Total Bill: $totalBill'),
                      Text('Payment Method: $paymentMethod'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
