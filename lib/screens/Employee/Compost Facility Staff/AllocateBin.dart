import 'package:flutter/material.dart';

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
      body: const Center(
        child: Text('Allocate bins to waste here'),
      ),
    );
  }
}
