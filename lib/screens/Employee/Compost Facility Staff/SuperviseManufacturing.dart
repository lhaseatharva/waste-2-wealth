import 'package:flutter/material.dart';

class SuperviseManufacturing extends StatefulWidget {
  @override
  _SuperviseManufacturingState createState() => _SuperviseManufacturingState();
}

class _SuperviseManufacturingState extends State<SuperviseManufacturing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Manufacturing Supervision'),
      ),
      body: const Center(
        child: Text('Check manufacturing status'),
      ),
    );
  }
}
