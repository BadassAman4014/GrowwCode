import 'package:flutter/material.dart';
import 'package:growwcode/Knowledge_Portal/FertiliserPedia/test_NutrientManagement.dart';

class CropSelectionPage extends StatefulWidget {
  @override
  _CropSelectionPageState createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage> {
  final List<String> selectedCrops = [];
  final Map<String, List<String>> categories = {
    "Grains": ["Wheat", "Rice", "Corn", "Barley"],
    "Vegetables": ["Carrot", "Tomato", "Potato", "Onion"],
    "Fruits": ["Apple", "Banana", "Orange", "Mango"],
    "Pulses": ["Black Gram", "Pigeon Pea", "Green Pea", "Soyabean"],
    "Cash Crops": ["Cotton", "Sugarcane", "Jute", "Coffee"],
  };

  void toggleCropSelection(String crop) {
    setState(() {
      if (selectedCrops.contains(crop)) {
        selectedCrops.remove(crop);
      } else {
        selectedCrops.add(crop);
      }
    });
  }

  void navigateToNutrientManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NutrientManagementPage(selectedCrops: selectedCrops),
      ),
    );
  }

  String getCropImagePath(String category, String crop) {
    String formattedCropName = crop.toLowerCase().replaceAll(" ", "_");
    return "assets/Crop_Selection/${category.replaceAll(' ', '_')}/$formattedCropName.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Selection"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          if (selectedCrops.isNotEmpty)
            Container(
              height: 140,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedCrops.map((crop) {
                    String category = categories.keys.firstWhere(
                          (key) => categories[key]!.contains(crop),
                      orElse: () => "",
                    );
                    String imagePath = getCropImagePath(category, crop);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                color: Colors.green,
                                width: 2,
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
                    );
                  }).toList(),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: categories.keys.map((category) {
                  List<String> crops = categories[category]!;
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), // Added padding
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8, // Adjusted for image and text
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: crops.length,
                          itemBuilder: (context, cropIndex) {
                            String crop = crops[cropIndex];
                            bool isSelected = selectedCrops.contains(crop);
                            String imagePath = getCropImagePath(category, crop);

                            return GestureDetector(
                              onTap: () => toggleCropSelection(crop),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.transparent,
                                            width: 2,
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
                                      if (isSelected)
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                        ),
                                    ],
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
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: navigateToNutrientManagement,
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
