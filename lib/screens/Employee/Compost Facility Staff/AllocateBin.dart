import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllocateBin extends StatefulWidget {
  @override
  _AllocateBinState createState() => _AllocateBinState();
}

class _AllocateBinState extends State<AllocateBin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Compost Bin Allocation'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Bins').snapshots(),
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
            final bins = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bins.length,
              itemBuilder: (context, index) {
                final bin = bins[index];
                final binName = bin.id;
                final binMaxQty = bin['maxQuantity'];
                final binCurrQty = bin['currQuantity'];

                return ListTile(
                  title: Text('Bin Name: $binName'),
                  subtitle: Text('Max Quantity: $binMaxQty\nCurrent Quantity: $binCurrQty'),
                  onTap: () {
                    _showAllocationForm(context, binName);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _showAllocationForm(BuildContext context, String binName) async {
    TextEditingController quantityController = TextEditingController();
    DateTime now = DateTime.now();
    DateTime completionDate = now.add(Duration(days: 30));

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allocate Bin: $binName'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int quantity = int.tryParse(quantityController.text) ?? 0;
                await _saveAllocationData(binName, quantity, now, completionDate);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAllocationData(String binName, int quantity, DateTime startDate, DateTime completionDate) async {
    try {
      await FirebaseFirestore.instance.collection('Bins').doc(binName).update({
        'currQuantity': FieldValue.increment(quantity),
        'filledAt': startDate,
        'completedAt': completionDate,
      });
      print('Allocation data saved successfully');
    } catch (error) {
      print('Error saving allocation data: $error');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: AllocateBin(),
  ));
}
