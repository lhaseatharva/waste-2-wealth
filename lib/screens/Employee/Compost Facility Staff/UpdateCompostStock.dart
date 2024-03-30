import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCompostStock extends StatefulWidget {
  @override
  _UpdateCompostStockState createState() => _UpdateCompostStockState();
}

class _UpdateCompostStockState extends State<UpdateCompostStock> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  String? _selectedType;

  final List<String> _compostTypes = ['Vermicompost', 'Organic Compost'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Compost Stock Updation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                items: _compostTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Type of Compost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the type of compost';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rateController,
                decoration: InputDecoration(labelText: 'Rate'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveCompostStock();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCompostStock() {
    final double quantity = double.parse(_quantityController.text);
    final double rate = double.parse(_rateController.text);

    final compostStockRef = FirebaseFirestore.instance.collection('Compost Stock').doc(_selectedType);

    compostStockRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        // Update existing document
        compostStockRef.update({
          'quantity': FieldValue.increment(quantity),
          'rate': rate,
          'updatedAt': DateTime.now(),
        }).then((_) {
          _quantityController.clear();
          _rateController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Compost stock updated successfully')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update compost stock: $error')),
          );
        });
      } else {
        // Add new document
        compostStockRef.set({
          'type': _selectedType,
          'quantity': quantity,
          'rate': rate,
          'createdAt': DateTime.now(),
        }).then((_) {
          _quantityController.clear();
          _rateController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New compost stock added successfully')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add new compost stock: $error')),
          );
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check existing compost stock: $error')),
      );
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: UpdateCompostStock(),
  ));
}
