import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'Fertiliser_Recommendation_Result.dart';

class FertilizerForm extends StatefulWidget {
  const FertilizerForm({super.key});

  @override
  State<FertilizerForm> createState() => _FertilizerFormState();
}

class _FertilizerFormState extends State<FertilizerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedCrop;
  final List<String> cropTypes = ['Rice', 'Sugarcane', 'Tomato', 'Onion', 'Cotton', 'Soybean'];

  // Map to store stages for each crop
  Map<String, List<String>> cropStages = {
    'Rice': ['Germination', 'Seedling', 'Vegetative', 'Reproductive', 'Maturity'],
    'Sugarcane': ['Germination', 'Vegetative Growth', 'Maturation', 'Harvest'],
    'Tomato': ['Germination', 'Seedling', 'Vegetative Growth', 'Flowering', 'Fruit Set', 'Maturity'],
    'Onion': ['Germination', 'Vegetative', 'Bulb Formation', 'Maturity'],
    'Cotton': ['Germination', 'Seedling', 'Vegetative Growth', 'Flowering', 'Boll Formation', 'Maturity'],
    'Soybean': ['Germination', 'Vegetative Growth', 'Flowering', 'Pod Development', 'Maturity'],
  };

  List<String> plantStages = []; // To store stages based on selected crop

  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController moistureController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();
  final TextEditingController landAcresController = TextEditingController();

  String? selectedPlantStage;
  String cityName = "Unknown"; // City name initialized here

  // Firebase variables
  List<String> sensorNames = []; // List of sensor names
  Map<String, String> sensorDataMap = {}; // Map sensor name to its key
  String? selectedSensor;

  bool nutrientDataAvailable = true; // Track the state of the checkbox

  Future<void> fetchData() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get city name from coordinates using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        cityName = placemarks.first.locality ?? "Unknown";
      });
    } catch (e) {
      print("Error fetching location data: $e");
    }
  }

  @override
  void dispose() {
    nController.dispose();
    pController.dispose();
    kController.dispose();
    tempController.dispose();
    humidityController.dispose();
    moistureController.dispose();
    phController.dispose();
    rainfallController.dispose();
    landAcresController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultPage(
            crop: selectedCrop ?? 'Most harvested Crop at $cityName',
            plantStage: selectedPlantStage ?? 'General stage',
            nitrogen: nController.text.isNotEmpty ? nController.text : '0',
            phosphorus: pController.text.isNotEmpty ? pController.text : '0',
            potassium: kController.text.isNotEmpty ? kController.text : '0',
            temperature: tempController.text.isNotEmpty ? tempController.text : '25',
            humidity: humidityController.text.isNotEmpty ? humidityController.text : '50',
            moisture: moistureController.text.isNotEmpty ? moistureController.text : '30',
            ph: phController.text.isNotEmpty ? phController.text : '7.0',
            rainfall: rainfallController.text.isNotEmpty ? rainfallController.text : '100',
            landAcres: landAcresController.text.isNotEmpty ? landAcresController.text : '1',
            location: cityName,
          ),
        ),
      );
    }
  }

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

  // Fetch data for the selected sensor
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
          nController.text = data['N']?.toString() ?? '';
          pController.text = data['P']?.toString() ?? '';
          kController.text = data['K']?.toString() ?? '';
          tempController.text = data['temperature']?.toString() ?? '';
          humidityController.text = data['humidity']?.toString() ?? '';
          moistureController.text = data['moisture']?.toString() ?? '';
          phController.text = data['ph']?.toString() ?? '';
          rainfallController.text = data['rainfall']?.toString() ?? '';
        });
      } else {
        print("No data available for the selected sensor.");
      }
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData(); // Fetch the sensor data when the screen loads
    fetchData(); // Fetch the city name and location when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          children: [
            const Text(
              'Fertilizer Recommendation',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(6.5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center align horizontally
                        crossAxisAlignment: CrossAxisAlignment.center, // Center align vertically
                        children: [
                          Icon(Icons.location_on, color: Colors.green, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cityName ?? 'Fetching location...',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center, // Center align text
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Crop Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Crop Type',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedCrop,
                      items: cropTypes.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCrop = value;
                          // Update stages based on selected crop
                          plantStages = cropStages[value!] ?? [];
                          selectedPlantStage = null; // Reset selected plant stage
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Plant Stage Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Plant Stage',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedPlantStage,
                      items: plantStages.map((stage) {
                        return DropdownMenuItem<String>(
                          value: stage,
                          child: Text(stage),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPlantStage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8.0),

                    // Land Size, N, P, K, etc.
                    buildTextField(landAcresController, 'Land Size (acres)'),

                    // Sensor Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Sensor',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedSensor,
                      items: sensorNames.map((sensor) {
                        return DropdownMenuItem<String>(
                          value: sensor,
                          child: Text(sensor),
                        );
                      }).toList(),
                      onChanged: nutrientDataAvailable ? (value) {
                        setState(() {
                          selectedSensor = value;
                          fetchDataForSelectedSensor(); // Fetch data for the selected sensor
                        });
                      } : null,
                    ),

                    // Nutrient data available checkbox
                    CheckboxListTile(
                      title: Text('Nutrient data available?'),
                      value: nutrientDataAvailable,
                      onChanged: (value) {
                        setState(() {
                          nutrientDataAvailable = value ?? false;
                        });
                      },
                    ),

                    // Nutrient Fields (N, P, K, etc.)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Text(
                        "Nutrient Values",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    buildRowTextField(nController, 'Nitrogen (N)', pController, 'Phosphorus (P)'),
                    buildRowTextField(kController, 'Potassium (K)', tempController, 'Temperature'),
                    buildRowTextField(humidityController, 'Humidity', moistureController, 'Soil Moisture'),
                    buildRowTextField(phController, 'pH', rainfallController, 'Rainfall'),

                    // Submit Button
                    ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 40), // Adjust height here (50 is an example)
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white), // Set text color to white
                      ),
                    ),


                  ]
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget buildRowTextField(TextEditingController controller1, String labelText1,
      TextEditingController controller2, String labelText2) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: SizedBox(
              height: 50,
              child: TextFormField(
                controller: controller1,
                enabled: nutrientDataAvailable,
                decoration: InputDecoration(
                  labelText: labelText1,
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: SizedBox(
              height: 50,
              child: TextFormField(
                controller: controller2,
                enabled: nutrientDataAvailable,
                decoration: InputDecoration(
                  labelText: labelText2,
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
