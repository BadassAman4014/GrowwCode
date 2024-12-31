import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'QR_Scanner.dart';

class SensorMaagement extends StatefulWidget {
  const SensorMaagement({Key? key}) : super(key: key);

  @override
  State<SensorMaagement> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SensorMaagement> {
  // List to hold the sensors fetched from Firebase
  List<Map<String, dynamic>> _sensors = [];

  final DatabaseReference _sensorsRef = FirebaseDatabase.instance.ref('sensors');

  @override
  void initState() {
    super.initState();
    _fetchSensors();
  }

  // Fetch the sensors from Firebase Realtime Database and handle duplicates
  // Future<void> _fetchSensors() async {
  //   final snapshot = await _sensorsRef.get();
  //
  //   if (snapshot.exists) {
  //     List<Map<String, dynamic>> sensorsList = [];
  //     Map sensorsMap = snapshot.value as Map;
  //
  //     // Add sensors to the list and check for duplicates
  //     Map<String, String> seenCodes = {}; // To track unique codes and their keys
  //     List<String> duplicateKeys = []; // To track duplicate sensor keys
  //
  //     sensorsMap.forEach((key, value) {
  //       String code = value['code'];
  //
  //       if (seenCodes.containsKey(code)) {
  //         // Duplicate detected
  //         duplicateKeys.add(key);
  //       } else {
  //         seenCodes[code] = key; // Add unique code to tracker
  //         sensorsList.add({
  //           'name': value['name'],
  //           'code': value['code'],
  //           'status': value['status'],
  //           'expanded': false,
  //           'id': key,  // Store Firebase key (id)
  //         });
  //       }
  //     });
  //
  //     // Delete duplicates from Firebase
  //     for (String duplicateKey in duplicateKeys) {
  //       await _sensorsRef.child(duplicateKey).remove();
  //     }
  //
  //     setState(() {
  //       _sensors = sensorsList;
  //     });
  //   } else {
  //     setState(() {
  //       _sensors = [];
  //     });
  //   }
  // }

  // Add sensor to Firebase
  Future<void> _fetchSensors() async {
    final snapshot = await _sensorsRef.get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> sensorsList = [];
      Map sensorsMap = snapshot.value as Map;

      // Add sensors to the list and check for duplicates
      Map<String, String> seenCodes = {}; // To track unique codes and their keys
      List<String> duplicateKeys = []; // To track duplicate sensor keys

      sensorsMap.forEach((key, value) {
        String code = value['code'];

        if (seenCodes.containsKey(code)) {
          // Duplicate detected
          duplicateKeys.add(key);
        } else {
          seenCodes[code] = key; // Add unique code to tracker
          sensorsList.add({
            'name': value['name'],
            'code': value['code'],
            'status': value['status'],
            'expanded': true, // Keep the sensor expanded by default
            'id': key,  // Store Firebase key (id)
          });
        }
      });

      // Delete duplicates from Firebase
      for (String duplicateKey in duplicateKeys) {
        await _sensorsRef.child(duplicateKey).remove();
      }

      setState(() {
        _sensors = sensorsList;
      });
    } else {
      setState(() {
        _sensors = [];
      });
    }
  }

  void _addSensor(Map<String, dynamic> sensor) {
    _sensorsRef.push().set({
      'name': sensor['name'],
      'code': sensor['code'],
      'status': 'Online',
    }).then((_) {
      _fetchSensors();  // Refresh the list after adding the sensor
    });
  }

  // Update sensor status
  void _updateSensorStatus(int index, String status) {
    setState(() {
      _sensors[index]['status'] = status;
    });
  }

  // Toggle sensor expansion state
  void _toggleExpand(int index) {
    setState(() {
      _sensors[index]['expanded'] = !_sensors[index]['expanded'];
    });
  }

  // Delete sensor from Firebase
  void _deleteSensor(String sensorId) {
    _sensorsRef.child(sensorId).remove().then((_) {
      _fetchSensors();  // Refresh the list after deleting the sensor
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sensor Manager',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const Text(
            "Sensors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Displaying the list of all sensors
          ..._sensors.asMap().entries.map((entry) {
            int index = entry.key;
            var sensor = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  ListTile(
                    title: Text(sensor['name']),
                    subtitle: Text("Code: XHKNIShcedja12Jcxd"),
                    trailing: Text(
                      sensor['status'],
                      style: TextStyle(
                        color: sensor['status'] == "Online"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _toggleExpand(index);
                    },
                  ),
                  if (sensor['expanded'])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String newStatus = sensor['status'] == "Online"
                                ? "Offline"
                                : "Online";
                            _updateSensorStatus(index, newStatus);
                          },
                          child: const Text(
                            "Update Sensor",
                            style: TextStyle(color: Colors.blue),  // Set text color to red
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Delete the sensor
                            _deleteSensor(sensor['id']);
                          },
                          child: const Text(
                            "Delete Sensor",
                            style: TextStyle(color: Colors.red),  // Set text color to red
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Red color for delete
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final newSensor = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              );
              if (newSensor != null) {
                _addSensor(newSensor);  // Add new sensor
              }
            },
            child: const Text("Add Sensor"),
          ),
        ],
      ),
    );
  }
}
