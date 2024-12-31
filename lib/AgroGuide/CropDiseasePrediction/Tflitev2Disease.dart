import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../../API_Keys/api.dart';
import 'package:markdown/markdown.dart' as md;
import '../../Knowledge_Portal/FertiliserPedia/TEST_CROPSELECTION.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  String? detectedDisease; // Nullable to hide when no prediction
  double? confidencePercentage; // Nullable to hide when no prediction
  bool _isLoading = false;
  String location = "India";
  String? _diseaseDescription;
  String? _medicareDescription;
  String? _cultivationTipsDescription;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/TFModels/model_unquant.tflite",
      labels: "assets/TFModels/labels.txt",
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
          detectedDisease = null; // Reset previous predictions
          confidencePercentage = null;
        });

        // Show buffer icon for 2 seconds before prediction
        await Future.delayed(Duration(seconds: 2));
        detectImage(file!);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }


  // Future<void> detectImage(File image) async {
  //   setState(() {
  //     _isLoading = true;  // Start loading
  //   });
  //
  //   var recognitions = await Tflite.runModelOnImage(
  //     path: image.path,
  //     numResults: 1, // Fetch the top result only
  //     threshold: 0.05,
  //     imageMean: 127.5,
  //     imageStd: 127.5,
  //   );
  //
  //   if (recognitions != null && recognitions.isNotEmpty) {
  //     setState(() {
  //       String rawLabel = recognitions[0]["label"] ?? "Unknown Disease";
  //       detectedDisease = _extractDiseaseName(rawLabel);
  //       confidencePercentage = (recognitions[0]["confidence"] ?? 0.0) * 100;
  //     });
  //
  //     // Fetch Gemini API data after prediction
  //     await _fetchGeminiData();
  //     // Call _showModalSheet when disease is detected
  //     if (detectedDisease != null) {
  //       _showModalSheet(description: _diseaseDescription ?? "No description available.");
  //     }
  //   }
  //
  //   setState(() {
  //     _isLoading = false;  // Stop loading
  //   });
  // }

  // Helper function to extract and clean disease name
  Future<void> detectImage(File image) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1, // Fetch the top result only
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (recognitions == null || recognitions.isEmpty ||
        (recognitions[0]["label"] ?? "").contains("No Leaf")) {
      // Handle case when no relevant class is detected
      setState(() {
        detectedDisease = "No Leaf Detected";
        confidencePercentage = null;
        _isLoading = false; // Stop loading
      });
      _showAlertDialog(
        title: "No Leaf Detected",
        content: "Please upload an image with a leaf for analysis.",
      );
      return;
    }

    if (recognitions == null || recognitions.isEmpty ||
        (recognitions[0]["label"] ?? "").contains("Tomato Healthy")) {
      // Handle case when no relevant class is detected
      setState(() {
        detectedDisease = "No Leaf Detected";
        confidencePercentage = null;
        _isLoading = false; // Stop loading
      });
      _showHealthyDialog(
        title: "The Plant is healthy",
        content: "Fertilize with phosphorus and potassium, and add calcium to prevent fruit issues. "
            "Water deeply and regularly, using mulch to retain moisture. "
            "Prune suckers, stake or cage the plant, and ensure 6-8 hours of sunlight daily. "
            "Inspect for pests or diseases and encourage pollination with flowers or gentle shaking. "
            "Harvest ripe tomatoes regularly and consider planting more for a longer harvest season.",
      );
      return;
    }

    // If a valid class is detected
    setState(() {
      String rawLabel = recognitions[0]["label"] ?? "Unknown Disease";
      detectedDisease = _extractDiseaseName(rawLabel);
      confidencePercentage = (recognitions[0]["confidence"] ?? 0.0) * 100;
    });

    // Fetch Gemini API data
    if (detectedDisease != null) {
      await _fetchGeminiData();
      _showModalSheet(description: _diseaseDescription ?? "No description available.");
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  void _showAlertDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showHealthyDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold, // Makes the text bold
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }


  String _extractDiseaseName(String rawLabel) {
    final RegExp pattern = RegExp(r'^\d+\s*'); // Remove numeric prefixes
    return rawLabel.replaceAll(pattern, '').trim();
  }

  // Fetching data from Gemini API
  Future<void> _fetchGeminiData() async {
    if (detectedDisease == null) return;

    try {
      // Disease description
      String description = await GeminiAPI.getGeminiData(
        "I am a farmer from $location. My crop is suffering from $detectedDisease. Please provide the output only about - Plant Disease Description (4 lines): Give a concise paragraph describing the cause, symptoms, and conditions provoking the specified crop disease.",
      );
      setState(() {
        _diseaseDescription = description;
      });

      // Medicare (Cure) recommendations
      _medicareDescription = await GeminiAPI.getGeminiData(
        "I am a farmer from $location. My crop is suffering from $detectedDisease. Please provide the output only about - Medicare (Cure) (5 numbered points with only content): Provide accurate and appropriate measures and medications for treating plants affected by the specified disease.",
      );

      // Cultivation Tips
      _cultivationTipsDescription = await GeminiAPI.getGeminiData(
        "I am a farmer from $location. My crop is suffering from $detectedDisease. Please provide the output only about - Cultivation Tips (6 numbered points ): Offer cultivation tips to help users prevent the occurrence of the diagnosed disease in their crops. Additionally, provide advice on how to safeguard other plants from being affected and prevent the disease from spreading further.",
      );
    } catch (e) {
      print("Error fetching Gemini data: $e");
    }
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
          'Scan your plant',
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 430,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green, // Green border color
                        width: 3.5,         // Border width
                      ),
                      image: DecorationImage(
                        image: _image != null
                            ? FileImage(File(_image!.path))
                            : const AssetImage("assets/icons/Plant scanner.gif")
                        as ImageProvider,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ElevatedButton.icon(
                  //   onPressed: _pickImage,
                  //   icon: const Icon(Icons.image, color: Colors.white),
                  //   label: const Text(
                  //     'Select Image',
                  //     style: TextStyle(
                  //       color: Colors.white, // Sets the text color to white
                  //     ),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  //     backgroundColor: Colors.green,
                  //     elevation: 8.0, // Sets elevation to give a shadow effect
                  //     shadowColor: Colors.black54, // Optional: Adjust shadow color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  // ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Choose from Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Take a Photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      'Upload Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                      backgroundColor: Colors.green,
                      elevation: 8.0,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display Disease and Confidence Results if available
                  if (detectedDisease != null && confidencePercentage != null) ...[
                    Text(
                      "Disease: $detectedDisease",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Confidence: ${confidencePercentage!.toStringAsFixed(2)}%",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Background blur when loading
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          // Loading Indicator in the center
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.green,),
            ),
        ],
      ),
    );
  }

  void _showModalSheet({required String description}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.75,
          initialChildSize: 0.25,
          minChildSize: 0.25,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detectedDisease ?? "",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            width: 150,
                            child: _buildSectionCard(
                              title: 'Medicare (Cure)',
                              image: "assets/icons/hand.png",
                              onTap: () {
                                print('Medicare (Cure) tapped');
                                _showMedicareDescription();
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 150,
                            child: _buildSectionCard(
                              title: 'Cultivation Tips',
                              image: "assets/icons/organic.png",
                              onTap: () {
                                print('Cultivation Tips tapped');
                                _showCultivationTipsDescription();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(12),
                              backgroundColor: Color(0xFF003032),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to 'More Info' page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CropSelectionPage()),
                              );
                            },
                            child: Text(
                              'Know More !!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Helper method to build section cards
  Widget _buildSectionCard({required String title, required String image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            Image.asset(
              image,
              width: 50,  // Adjust image size as needed
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),  // Space between image and text
            Text(
              title,
              textAlign: TextAlign.center, // Center align text
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicareDescription() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.75,
          initialChildSize: 0.25,
          minChildSize: 0.25,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicare (Cure)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    _medicareDescription != null
                        ? Html(
                      data: md.markdownToHtml(_medicareDescription!),
                    )
                        : Text(
                      "No description available.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCultivationTipsDescription() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.75,
          initialChildSize: 0.25,
          minChildSize: 0.25,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cultivation Tips',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    _cultivationTipsDescription != null
                        ? Html(
                      data: md.markdownToHtml(_cultivationTipsDescription!),
                    )
                        : Text(
                      "No tips available.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
