import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'soil_report.dart';

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  Map<String, String> sensorValues = {};
  String? selectedPlantType;
  final List<String> plantTypes = ['Rice', 'Sugarcane', 'Cotton', 'Tomato', 'Soyabean', 'Onion'];

  final Map<String, Map<String, Map<String, double>>> plantThresholds = {
    'Rice': {
      'Temperature': {'min': 22.0, 'max': 32.0},
      'Humidity': {'min': 70.0, 'max': 90.0},
      'Moisture': {'min': 60.0, 'max': 80.0},
      'Rainfall': {'min': 1200.0, 'max': 1800.0},
      'Nitrogen': {'min': 40.0, 'max': 60.0},
      'Phosphorus': {'min': 20.0, 'max': 30.0},
      'Potassium': {'min': 30.0, 'max': 50.0},
    },
    'Sugarcane': {
      'Temperature': {'min': 25.0, 'max': 35.0},
      'Humidity': {'min': 60.0, 'max': 80.0},
      'Moisture': {'min': 60.0, 'max': 80.0},
      'Rainfall': {'min': 1000.0, 'max': 1500.0},
      'Nitrogen': {'min': 60.0, 'max': 80.0},
      'Phosphorus': {'min': 25.0, 'max': 35.0},
      'Potassium': {'min': 40.0, 'max': 60.0},
    },
    'Cotton': {
      'Temperature': {'min': 20.0, 'max': 30.0},
      'Humidity': {'min': 50.0, 'max': 70.0},
      'Moisture': {'min': 40.0, 'max': 60.0},
      'Rainfall': {'min': 600.0, 'max': 800.0},
      'Nitrogen': {'min': 30.0, 'max': 50.0},
      'Phosphorus': {'min': 20.0, 'max': 30.0},
      'Potassium': {'min': 30.0, 'max': 50.0},
    },
    'Tomato': {
      'Temperature': {'min': 18.0, 'max': 28.0},
      'Humidity': {'min': 60.0, 'max': 80.0},
      'Moisture': {'min': 50.0, 'max': 70.0},
      'Rainfall': {'min': 400.0, 'max': 600.0},
      'Nitrogen': {'min': 40.0, 'max': 60.0},
      'Phosphorus': {'min': 20.0, 'max': 30.0},
      'Potassium': {'min': 30.0, 'max': 50.0},
    },
    'Soybean': {
      'Temperature': {'min': 20.0, 'max': 30.0},
      'Humidity': {'min': 55.0, 'max': 75.0},
      'Moisture': {'min': 50.0, 'max': 70.0},
      'Rainfall': {'min': 800.0, 'max': 1200.0},
      'Nitrogen': {'min': 50.0, 'max': 70.0},
      'Phosphorus': {'min': 25.0, 'max': 35.0},
      'Potassium': {'min': 40.0, 'max': 60.0},
    },
    'Onion': {
      'Temperature': {'min': 15.0, 'max': 25.0},
      'Humidity': {'min': 50.0, 'max': 70.0},
      'Moisture': {'min': 40.0, 'max': 60.0},
      'Rainfall': {'min': 300.0, 'max': 500.0},
      'Nitrogen': {'min': 30.0, 'max': 50.0},
      'Phosphorus': {'min': 20.0, 'max': 30.0},
      'Potassium': {'min': 30.0,'max':50.0},
    }

  };



  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController moistureController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();
  final TextEditingController landAcresController = TextEditingController();

  // Firebase variables
  List<String> sensorNames = []; // List of sensor names
  Map<String, String> sensorDataMap = {}; // Map sensor name to its key
  String? selectedSensor;

  // Fetch sensor data from Firebase
  Future<void> fetchSensorData() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('sensors');

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          sensorNames = [];
          sensorDataMap = {}; // Reset the map

          data.forEach((key, value) {
            var sensorName = value['name'];
            if (sensorName != null) {
              sensorNames.add(sensorName); // Add sensor name to the list
              sensorDataMap[sensorName] = key; // Map sensor name to its Firebase key
            }
          });
        });
      }
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  }

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) AwesomeNotifications().requestPermissionToSendNotifications();
    });
    super.initState();
    fetchSensorData(); // Fetch the sensor data when the screen loads
  }

  void _showInfoDialog(String value, String label, String description, double minThreshold, double maxThreshold, double currentValue) {
    final status = currentValue < minThreshold
        ? 'Below Safe Range'
        : currentValue > maxThreshold
        ? 'Above Safe Range'
        : 'Within Safe Range';

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(label),
        content: Text(
            '$description: $value\nStatus: $status\nSafe Range: $minThreshold - $maxThreshold'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Alert'),
        content: Text('Please select a plant first.'),
        actions: [TextButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop())],
      ),
    );
  }

  void _navigateToReportPage() {
    if (selectedPlantType != null) {
      final parsedValues = sensorValues.map((key, value) => MapEntry(key, double.parse(value.split(' ')[0])));
      final thresholds = plantThresholds[selectedPlantType!] ?? {};

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPage(
            selectedPlantType: selectedPlantType!,
            sensorValues: parsedValues,
            thresholds: thresholds, // Ensures this is non-nullable
          ),
        ),
      );
    } else {
      _showAlertDialog();
    }
  }

  Future<void> fetchDataForSelectedSensor() async {
    if (selectedSensor == null) {
      print("No sensor selected");
      return;
    }

    String sensorKey = sensorDataMap[selectedSensor!] ?? '';
    if (sensorKey.isEmpty) {
      print("No data found for this sensor.");
      return;
    }

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('sensors').child(sensorKey);

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          // Populate the fields with the sensor data
          nController.text = data['N'] != null ? data['N'].toString() : '';
          pController.text = data['P'] != null ? data['P'].toString() : '';
          kController.text = data['K'] != null ? data['K'].toString() : '';
          tempController.text = data['temperature'] != null ? data['temperature'].toString() : '';
          humidityController.text = data['humidity'] != null ? data['humidity'].toString() : '';
          moistureController.text = data['moisture'] != null ? data['moisture'].toString() : '';
          phController.text = data['ph'] != null ? data['ph'].toString() : '';
          rainfallController.text = data['rainfall'] != null ? data['rainfall'].toString() : '';

          // Convert string values to double or int
          sensorValues['Temperature'] = (data['temperature'] != null) ? double.parse(data['temperature'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Humidity'] = (data['humidity'] != null) ? double.parse(data['humidity'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Moisture'] = (data['moisture'] != null) ? double.parse(data['moisture'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Rainfall'] = (data['rainfall'] != null) ? double.parse(data['rainfall'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Nitrogen'] = (data['N'] != null) ? double.parse(data['N'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Phosphorus'] = (data['P'] != null) ? double.parse(data['P'].toString()).toStringAsFixed(2) : '0.0';
          sensorValues['Potassium'] = (data['K'] != null) ? double.parse(data['K'].toString()).toStringAsFixed(2) : '0.0';
        });
      }
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  }

  void _showColorInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Color Code Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient Bar
            Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.green, Colors.red],
                  stops: [0.0, 0.5, 1.0], // Gradient stops to center green
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 10),
            // Descriptions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.yellow, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Yellow: Below the recommended level (Deficiency).',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Green: Within the safe range.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Red: Above the recommended level (Excess).',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sensor Data',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 2.0,
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown to select sensor
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Sensor',
                border: OutlineInputBorder(),
              ),
              value: selectedSensor,
              items: sensorNames.map((sensorName) {
                return DropdownMenuItem<String>(
                  value: sensorName,
                  child: Text(sensorName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSensor = value;
                  fetchDataForSelectedSensor(); // Fetch data for the selected sensor
                });
              },
            ),
            SizedBox(height: 10),
            // Row for Plant Selection and Info Button
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButton<String>(
                    value: selectedPlantType,
                    hint: Text('Select a Plant'),
                    onChanged: (value) {
                      setState(() {
                        selectedPlantType = value;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(value: null, child: Text('Select a Plant')),
                      ...plantTypes.map((plant) =>
                          DropdownMenuItem<String>(value: plant, child: Text(plant))),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.info_outline, size: 30, color: Colors.blue),
                  onPressed: () {
                    _showColorInfoDialog();
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                children: [
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Temperature']} °C' : '—',
                    'Air Temperature',
                    Icons.thermostat_outlined,
                    'Current Air Temperature',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Temperature']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Temperature'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Humidity']} %' : '—',
                    'Humidity',
                    Icons.water_drop_outlined,
                    'Current Humidity Level',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Humidity']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Humidity'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Moisture']} %' : '—',
                    'Moisture',
                    Icons.opacity_outlined,
                    'Soil Moisture Level',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Moisture']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Moisture'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Rainfall']} mm' : '—',
                    'Rainfall',
                    Icons.cloud_outlined,
                    'Rainfall Amount',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Rainfall']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Rainfall'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Nitrogen']} (mg/L)' : '—',
                    'N Value',
                    Icons.grass_outlined,
                    'Nitrogen Content',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Nitrogen']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Nitrogen'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Phosphorus']} (mg/L)' : '—',
                    'P Value',
                    Icons.eco_outlined,
                    'Phosphorus Content',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Phosphorus']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Phosphorus'] ?? '0.0')
                        : 0.0,
                  ),
                  buildTile(
                    selectedSensor != null ? '${sensorValues['Potassium']} (mg/L)' : '—',
                    'K Value',
                    Icons.local_florist_outlined,
                    'Potassium Content',
                    selectedPlantType != null
                        ? (plantThresholds[selectedPlantType!] != null
                        ? plantThresholds[selectedPlantType!]!['Potassium']
                        : null)
                        : null,
                    selectedSensor != null
                        ? double.parse(sensorValues['Potassium'] ?? '0.0')
                        : 0.0,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _navigateToReportPage,  // Call _navigateToReportPage when button is pressed
              child: const Text(
                'View Report',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget buildTile(
      String value,
      String label,
      IconData icon,
      String description,
      Map<String, double>? thresholds,
      double currentValue,
      ) {
    // Check if a plant or sensor is selected
    if (selectedPlantType == null || selectedSensor == null) {
      return Card(
        margin: EdgeInsets.all(8),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.grey), // Default icon color
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey), // Default text color
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey), // Default text color
            ),
          ],
        ),
      );
    }

    double minThreshold = thresholds?['min'] ?? 0.0;
    double maxThreshold = thresholds?['max'] ?? 100.0;

    // Determine the color of the card based on the value and thresholds
    Color cardColor;

    if (currentValue > maxThreshold) {
      cardColor = Colors.red; // Above max threshold
    } else if (currentValue < minThreshold) {
      cardColor = Colors.yellow; // Below min threshold
    } else {
      cardColor = Colors.green; // Within safe range
    }

    return GestureDetector(
      onTap: () => _showInfoDialog(value, label, description, minThreshold, maxThreshold, currentValue),
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 4,
        color: cardColor, // Set the color of the card based on the conditions
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white), // Adjust icon color for contrast
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // Text color white for contrast
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.white), // Text color white for contrast
            ),
          ],
        ),
      ),
    );
  }
}