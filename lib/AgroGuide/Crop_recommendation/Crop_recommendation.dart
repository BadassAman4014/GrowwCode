import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../API_Keys/api.dart';
import 'Crop_recommendation_result_page.dart';

class CropRecommendation extends StatefulWidget {
  @override
  _CropRecommendationState createState() => _CropRecommendationState();
}

class _CropRecommendationState extends State<CropRecommendation> {
  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  var predValue = "";
  var predictedCrop = "";
  var errorMessages = Map<String, String>();
  var loading = false;
  String? userLocation;
  List<String> predition_labels = [];
  List<String> sensorNames = []; // Store sensor names (from the 'name' field)
  Map<String, String> sensorData = {}; // To map the sensor key to its name
  String? selectedSensor;

  // State variables for input values
  double n = 0.0;
  double p = 0.0;
  double k = 0.0;
  double temperature = 0.0;
  double humidity = 0.0;
  double ph = 0.0;
  double rainfall = 0.0;

  @override
  void initState() {
    super.initState();
    predValue = "Click predict button";
    fetchUserLocation();
    fetchSensorNames(); // Fetch sensor names from Firebase on initialization
  }

  // Fetch sensor names and map each sensor's key to the sensor name
  Future<void> fetchSensorNames() async {
    String path = "sensors"; // Path where the sensors are stored in Firebase
    DatabaseReference dbRef = FirebaseDatabase.instance.refFromURL(
        "https://growwcode-31cec-default-rtdb.asia-southeast1.firebasedatabase.app/$path");

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          // Extract sensor names and map them to sensor keys
          sensorNames = [];
          sensorData = {}; // Reset the map

          data.forEach((key, value) {
            var sensorName = value['name']; // Extract the name from each sensor's data
            if (sensorName != null) {
              sensorNames.add(sensorName);
              sensorData[sensorName] = key; // Map sensor name to its key
            }
          });
        });
      } else {
        print("No sensors available");
      }
    } catch (e) {
      print("Error fetching sensor names: $e");
    }
  }

  Future<void> fetchUserLocation() async {
    try {
      String location = await getAddressFromCoordinates();
      setState(() {
        userLocation = location; // Set the location to the class variable
      });
    } catch (e) {
      setState(() {
        userLocation = 'Failed to get location: $e';
      });
    }
  }

  // Fetch data for selected sensor from Firebase
  Future<void> fetchDataForSelectedSensor() async {
    if (selectedSensor == null) {
      print("No sensor selected");
      return;
    }

    String sensorKey = sensorData[selectedSensor!] ?? '';
    if (sensorKey.isEmpty) {
      print("No data found for this sensor.");
      return;
    }

    String path = "sensors/$sensorKey"; // Path for the selected sensor
    DatabaseReference dbRef = FirebaseDatabase.instance.refFromURL(
        "https://growwcode-31cec-default-rtdb.asia-southeast1.firebasedatabase.app/$path");

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          // Populate fields with the selected sensor's data
          nController.text = data['N']?.toString() ?? '';
          pController.text = data['P']?.toString() ?? '';
          kController.text = data['K']?.toString() ?? '';
          tempController.text = data['temperature']?.toString() ?? '';
          humidityController.text = data['humidity']?.toString() ?? '';
          phController.text = data['ph']?.toString() ?? '';
          rainfallController.text = data['rainfall']?.toString() ?? '0';
        });

        print("Data fetched successfully for $selectedSensor: $data");
      } else {
        print("No data available for this sensor.");
      }
    } catch (e) {
      print("Error fetching sensor data: $e");
    }
  }

  // Build text field for input
  Widget buildTextField(String label, TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF003032), width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black),
            ),
            style: TextStyle(color: Colors.black),
            controller: controller,
          ),
        ],
      ),
    );
  }

  Future<String> getAddressFromCoordinates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled. Please enable them.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied. We cannot request permissions.';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address = '${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      return address;
    } else {
      return 'Address not found';
    }
  }

  Future<List<String>> fetchLabel(List<List<double>> input) async {

    String location = userLocation ?? 'Unknown location';


    String recommend_crop = await GeminiAPI.getGeminiData(
        "Assume the role of an Indian crop recommendation expert. Recommend 5 crops strictly in comma-separated format without any details, just list of crops"+
            "Based on the average soil type and climate conditions of $location as well as soil parameters such as "+
            "Nitrogen (N): $n, Phosphorus (P): $p, Potassium (K): $k, Soil pH: $ph, Average Temperature: $temperature°C, Humidity: $humidity%, Annual Rainfall: $rainfall mm " + "The following criteria should be met:"+
            "The recommended crops should suit the soil type and climatic conditions prevalent in Telangana." +
            "The crops should be internally compatible, meaning they should have similar requirements for soil, water, and climate to support co-cultivation or rotation."+
            "Provide credible references or data sources (e.g., agricultural reports, government guidelines) to validate the recommendations." );


    // Regex pattern to match the crops listed with numbers (e.g., "1. Paddy", "2. Maize")
    RegExp regExp = RegExp(r'\d+\.\s*([A-Za-z\s]+)');

    // Find all matches of the crops using the regex
    Iterable<Match> matches = regExp.allMatches(recommend_crop);

    // Extract the crop names and store them in a list
    List<String> labels = matches.map((match) => match.group(1)!.trim()).toList();

    print(labels);


    return labels;

  }


  Future<void> predData() async {
    setState(() {
      errorMessages = {};
      loading = true;
    });

    final interpreter =
    await Interpreter.fromAsset('assets/crop_recommendation_model.tflite');

    // Parse input values
    double n = double.tryParse(nController.text) ?? 0.0;
    double p = double.tryParse(pController.text) ?? 0.0;
    double k = double.tryParse(kController.text) ?? 0.0;
    double temperature = double.tryParse(tempController.text) ?? 0.0;
    double humidity = double.tryParse(humidityController.text) ?? 0.0;
    double ph = double.tryParse(phController.text) ?? 0.0;
    double rainfall = double.tryParse(rainfallController.text) ?? 0.0;

    var input = [[n, p, k, temperature, humidity, ph, rainfall]];
    var output = List.filled(22, 0).reshape([1, 22]);
    interpreter.run(input, output);

    List<double> probabilities = List<double>.from(output[0]);
    List<int> sortedIndices = List.generate(probabilities.length, (i) => i)
      ..sort((a, b) => probabilities[b].compareTo(probabilities[a]));

    List<String> labels = fetchLabel(input) as List<String>;

    List<String> topCrops = sortedIndices.take(5).map((i) => labels[i]).toList();

    // Fetch location details
    String location = await getAddressFromCoordinates();

    setState(() {
      loading = false;
    });

    // Show the dialog box with the top 5 crops
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.green, width: 3), // Green outline around the AlertDialog
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Top 5 Recommended Crops",
                style: TextStyle(fontSize: 18), // Set your desired font size
              ),
              Divider(
                color: Colors.green,   // Green color for the separator
                thickness: 2,          // Increase the thickness of the separator
                indent: 0,             // Optional: Control the start indentation
                endIndent: 0,          // Optional: Control the end indentation
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: topCrops.asMap().entries.map((entry) {
              int index = entry.key;
              String crop = entry.value;
              return ListTile(
                title: Text("${index + 1}. $crop"), // Enumerating crops
                onTap: () async {
                  // Show a loading dialog while the result is being fetched
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Prevent dismissal by tapping outside
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator(color: Colors.green));
                    },
                  );

                  // Close the dialog when the data is fetched
                  predictedCrop = crop;

                  // Generate detailed guide for the selected crop
                  String result = await GeminiAPI.getGeminiData(
                      "I am a farmer based in $location, and my soil conditions include the following: " +
                          "Nitrogen (N): $n, Phosphorus (P): $p, Potassium (K): $k, and a soil pH of $ph. " +
                          "The average temperature in the area is $temperature°C, with a humidity level of $humidity%. " +
                          "The annual rainfall is $rainfall mm. Considering these conditions and the current time of the year, " +
                          "I have decided to grow $predictedCrop. Please provide me with a comprehensive and professional guide " +
                          "for growing this crop efficiently, taking into account the soil and weather conditions."
                  );

                  // Close the loading dialog
                  Navigator.of(context).pop();

                  // Navigate to the result page
                  await Get.to(ResultPage(result: result, predictedCrop: predictedCrop));
                },
              );
            }).toList(),
          ),
        );
      },
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
          'Crop Recommendation',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 2.0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown for selecting sensor
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10), // Padding inside the border
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[400]!, // Border color
                          width: 1.5, // Border width
                        ),
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton<String>(
                        hint: Text(
                          "Select Sensor",
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                        value: selectedSensor,
                        onChanged: (String? newSensor) {
                          setState(() {
                            selectedSensor = newSensor;
                          });
                          fetchDataForSelectedSensor(); // Fetch data for selected sensor
                        },
                        items: sensorNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          );
                        }).toList(),
                        isExpanded: true, // Makes the dropdown expand to fit the available space
                        style: TextStyle(fontSize: 16, color: Colors.black), // Text style for the selected item
                        underline: Container(), // Removes the default underline
                        icon: Icon(
                          Icons.arrow_drop_down, // Customize the dropdown icon
                          color: Colors.black,
                        ),
                        iconSize: 24, // Customize the size of the dropdown icon
                      ),
                    ),
                    // Input fields
                    buildTextField("Nitrogen", nController, ""),
                    buildTextField("Phosphorus", pController, ""),
                    buildTextField("Potassium", kController, ""),
                    buildTextField("Temperature", tempController, ""),
                    buildTextField("Humidity", humidityController, ""),
                    buildTextField("pH value", phController, ""),
                    buildTextField("Rainfall", rainfallController, ""),
                    SizedBox(height: 20.0),

                    // Predict Button
                    ElevatedButton(
                      onPressed: () async {
                        // Ensure the fields are updated based on the current text from the controllers
                        setState(() {
                          n = double.tryParse(nController.text) ?? 0.0;
                          p = double.tryParse(pController.text) ?? 0.0;
                          k = double.tryParse(kController.text) ?? 0.0;
                          temperature = double.tryParse(tempController.text) ?? 0.0;
                          humidity = double.tryParse(humidityController.text) ?? 0.0;
                          ph = double.tryParse(phController.text) ?? 0.0;
                          rainfall = double.tryParse(rainfallController.text) ?? 0.0;
                        });

                        // Show a loading dialog while waiting for the response
                        showDialog(
                          context: context,
                          barrierDismissible: false, // Prevent dismissal by tapping outside
                          builder: (BuildContext context) {
                            return Center(child: CircularProgressIndicator(color: Colors.green));
                          },
                        );

                        // Call fetchLabel function with the current input values
                        List<String> labels = await fetchLabel([
                          [n, p, k, temperature, humidity, ph, rainfall]
                        ]);

                        // Handle the result labels (e.g., show them in a dialog or process further)
                        if (labels.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Recommended Crops"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: labels.map((crop) => Text(crop)).toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Close"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Recommend',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 10),
                      Text('Loading...', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}