import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../API_Keys/api.dart';
import 'GrowthStageData.dart';

String address = '';

class NutrientManagementPage extends StatefulWidget {
  final List<String> selectedCrops;

  NutrientManagementPage({required this.selectedCrops});

  @override
  _NutrientManagementPageState createState() => _NutrientManagementPageState();
}

class _NutrientManagementPageState extends State<NutrientManagementPage> {
  String? selectedCrop;
  List<Map<String, dynamic>> growthStages = [];
  bool isLoadingGrowthStages = false;
  bool _isLoading = false;
  String _apiResponse = '';
  String? userLocation;

  // Predefined stage orders for Rice and Sugarcane
  final List<String> riceGrowthStages = [
    "Nursery bed preparation",
    "Nursery Sowing",
    "Germination",
    "Seedling",
    "Transplanting",
    "Tillering",
    "Internode Elongation",
    "Panicle Initiation and Booting",
    "Flowering",
    "Milk stage",
    "Dough Stage",
    "Maturity",
    "Harvesting"
  ];

  final List<String> sugarcaneGrowthStages = [
    "Field Preparation",
    "Plantation",
    "Germination",
    "Tillering",
    "Internode Elongation",
    "Sugar accumulation",
    "Harvesting"
  ];

  final List<String> TomatoGrowthStages = [
    "Nursery",
    "Transplanting",
    "Seedling",
    "Vegetative",
    "Flowering",
    "Fruit Development",
    "Harvesting"
  ];



  @override
  void initState() {
    super.initState();
    if (widget.selectedCrops.isNotEmpty) {
      selectedCrop = widget.selectedCrops.first; // Default selected crop
      fetchUserLocation().then((_) {
        fetchGrowthStages(selectedCrop!); // Fetch growth stages after location
        fetchBestVarieties(); // Fetch best varieties after location
      });
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
      return '${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
    } else {
      return 'Address not found';
    }
  }



  Future<void> fetchBestVarieties() async {
    setState(() {
      _isLoading = true;
    });

    String location = userLocation ?? 'Unknown location'; // Use the stored location


    String message = '''
    Consider yourself an expert Indian agricultural guide. Using Indian information references, Suggest 3 best varieties for growing $selectedCrop in $location  based on special features like - suitable regions, yeild in q/ha, maturity time, what pest and disease tolerant the variety is  and fertilizer requirement. Keep the response short and to the point covering all parameters. 
    Also give reference links for validating response information
    ''';

    try {
      String response = await GeminiAPI.getGeminiData(message);

      setState(() {
        _apiResponse = response.isNotEmpty ? response : 'No data received from the API.';
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Failed to fetch data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchGrowthStages(String crop) async {
    setState(() {
      isLoadingGrowthStages = true;
      growthStages = [];
    });
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("CropStageData")
          .doc(crop)
          .collection("Stages")
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> stagesList = querySnapshot.docs.map((doc) {
          return {
            "id": doc.id,
            ...doc.data(),
          };
        }).toList();

        if (crop == "Rice") {
          stagesList = reorderStages(stagesList, riceGrowthStages);
        } else if (crop == "Sugarcane") {
          stagesList = reorderStages(stagesList, sugarcaneGrowthStages);
        }else if (crop == "Tomato") {
          stagesList = reorderStages(stagesList, TomatoGrowthStages);
        }

        setState(() {
          growthStages = stagesList;
        });
      } else {
        setState(() {
          growthStages = [];
        });
      }
    } catch (e) {
      setState(() {
        growthStages = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching growth stages: $e")),
        );
      });
    } finally {
      setState(() {
        isLoadingGrowthStages = false;
      });
    }
  }

  List<Map<String, dynamic>> reorderStages(
      List<Map<String, dynamic>> stagesList, List<String> predefinedOrder) {
    Map<String, Map<String, dynamic>> stagesMap = {
      for (var stage in stagesList) stage["id"]: stage
    };

    List<Map<String, dynamic>> orderedStages = [];
    for (String stageName in predefinedOrder) {
      if (stagesMap.containsKey(stageName)) {
        orderedStages.add(stagesMap[stageName]!);
      }
    }
    return orderedStages;
  }

  String getCropImagePath(String category, String crop) {
    String formattedCropName = crop.toLowerCase().replaceAll(" ", "_");
    return "assets/Crop_Selection/$formattedCropName.png";
  }

  void selectCrop(String crop) {
    setState(() {
      selectedCrop = crop;
    });
    fetchGrowthStages(crop);
    fetchBestVarieties();
  }

  // Function to fetch image path for each stage dynamically based on the crop and stage
  String getStageImagePath(String crop, String stage) {
    // Format the crop and stage names to match the file names
    String formattedCropName = crop.toLowerCase().replaceAll(" ", "_");
    String formattedStageName = stage.toLowerCase().replaceAll(" ", "_");

    // Construct the full image path
    String imagePath = "assets/Growth_Stages/$formattedCropName/$formattedStageName.png";
    return imagePath;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrient Management',
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


      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.selectedCrops.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "My Crops",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.selectedCrops.length,
                      itemBuilder: (context, index) {
                        String crop = widget.selectedCrops[index];
                        String imagePath = getCropImagePath("Crops", crop);
                        bool isSelected = crop == selectedCrop; // Check if this crop is selected
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              selectCrop(crop); // Select crop when image is clicked
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    border: Border.all(
                                      color: isSelected ? Colors.green : Colors.white, // Highlight selected crop
                                      width: 3, // Thicker border for better visibility
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      imagePath,
                                      width: 60,
                                      height: 60,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  crop,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (selectedCrop != null && growthStages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Growth Stages for $selectedCrop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800], // Set the color to green
                      ),
                    ),
                    SizedBox(height: 16),
                    isLoadingGrowthStages
                        ? Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: growthStages.map((stage) {
                          // Get the image path dynamically for each stage
                          String imagePath = getStageImagePath(
                              selectedCrop!, stage["id"]);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StagewiseDetails(
                                      stageId: stage["id"],
                                      stageDetails: stage,
                                      cropName: selectedCrop!, // Pass the crop name here
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                                child: Container(
                                  width: 150,
                                  height: 225,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          getStageImagePath(selectedCrop!, stage["id"]),
                                          width: 150,
                                          height: 170,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.image_not_supported,
                                              size: 80,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment(0.0, 0.9),
                                          child: Text(
                                            stage["id"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 16,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

            if (selectedCrop != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Best Varieties of $selectedCrop for $userLocation",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : MarkdownBody(
                      data: _apiResponse,
                      styleSheet: MarkdownStyleSheet(
                        h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        p: TextStyle(fontSize: 16),
                        strong: TextStyle(fontWeight: FontWeight.bold),
                        em: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
}
