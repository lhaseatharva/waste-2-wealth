import 'package:flutter/material.dart';

class UpdateCompostStock extends StatefulWidget {
  @override
  _UpdateCompostStockState createState() => _UpdateCompostStockState();
}

class _UpdateCompostStockState extends State<UpdateCompostStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Compost Stock Updation'),
      ),
      body: const Center(
        child: Text('Update Compost Stock'),
      ),
    );
  }
}
