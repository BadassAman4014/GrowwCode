import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FoundCodeScreen extends StatefulWidget {
  final String value;
  final Function() screenClosed;

  const FoundCodeScreen({
    Key? key,
    required this.value,
    required this.screenClosed,
  }) : super(key: key);

  @override
  _FoundCodeScreenState createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  final TextEditingController sensorNameController = TextEditingController();
  bool isLoading = false;

  // Firebase reference to sensors
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensors');

  Future<void> _addSensorToFirebase(String name, String code) async {
    // Prevent further input while uploading
    if (isLoading) {
      print("Button press ignored: Already uploading...");
      return;
    }

    setState(() {
      isLoading = true;
    });

    print("Adding sensor to Firebase...");

    try {
      final sensorData = {
        'name': name,
        'code': code,
        'status': 'Online',
        'N': 0,
        'P': 0,
        'K': 0,
        'temperature': 0,
        'humidity': 0,
        'moisture': 0,
        'ph': 0,
      };

      // Push the data to Firebase
      await _sensorRef.push().set(sensorData);

      print("Sensor added successfully!");

      // If data is successfully pushed, navigate back with data
      if (mounted) {
        print("Navigating back with sensor data...");
        Navigator.pop(context, {
          'code': code,
          'name': name,
          'status': 'Online',
        });
      }
    } catch (e) {
      print("Error occurred while adding sensor: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to add sensor: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Sensor"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        leading: IconButton(
          onPressed: () {
            widget.screenClosed();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Scanned Code:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(widget.value, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: sensorNameController,
              decoration: InputDecoration(
                labelText: "Sensor Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () {
                final String name = sensorNameController.text.trim();
                if (name.isNotEmpty) {
                  _addSensorToFirebase(name, widget.value);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Please enter a sensor name."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text("Add Sensor"),
            ),
          ],
        ),
      ),
    );
  }
}
