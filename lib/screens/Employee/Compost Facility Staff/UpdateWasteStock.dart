import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateWasteStock extends StatefulWidget {
  @override
  _UpdateWasteStockState createState() => _UpdateWasteStockState();
}

class _UpdateWasteStockState extends State<UpdateWasteStock> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Waste Stock Updation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _restaurantNameController,
                decoration: const InputDecoration(labelText: 'Restaurant Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the restaurant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveWasteStock();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveWasteStock() async {
    final restaurantName = _restaurantNameController.text;
    final date = _dateController.text;
    final quantity = _quantityController.text;

    try {
      // Check if Waste Stock document exists for the restaurant, if not, create it
      final wasteStockRef = FirebaseFirestore.instance.collection('Waste Stock').doc(restaurantName);
      final snapshot = await wasteStockRef.get();
      if (!snapshot.exists) {
        await wasteStockRef.set({});
      }

      // Add waste stock data directly to the document
      await wasteStockRef.set({
        'date': date,
        'quantity': quantity,
      });

      // Clear form fields after saving
      _restaurantNameController.clear();
      _dateController.clear();
      _quantityController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waste stock saved successfully'),
        ),
      );
    } catch (error) {
      print('Error saving waste stock: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving waste stock'),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: UpdateWasteStock(),
  ));
}
