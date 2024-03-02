import 'package:flutter/material.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePage();
}

class _BuyerHomePage extends State<BuyerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade200,
        title: const Text('Buyer Home Page'),
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
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade100,
                foregroundColor: Colors.black,
              ),
              child: const Text('Place Order'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.lightGreen.shade100,
              ),
              child: const Text('Track Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: BuyerHomePage(),
    ),
  );
}
