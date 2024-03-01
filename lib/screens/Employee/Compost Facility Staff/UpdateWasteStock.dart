import 'package:flutter/material.dart';

class UpdateWasteStock extends StatefulWidget {
  @override
  _UpdateWasteStockState createState() => _UpdateWasteStockState();
}

class _UpdateWasteStockState extends State<UpdateWasteStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Waste Stock Updation'),
      ),
      body: const Center(
        child: Text('Update Waste Stock here'),
      ),
    );
  }
}
