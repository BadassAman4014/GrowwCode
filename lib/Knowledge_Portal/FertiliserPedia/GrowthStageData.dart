import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'StageWisePractices.dart'; // For rendering HTML content

class StagewiseDetails extends StatelessWidget {
  final String stageId; // Stage name, e.g., "Germination"
  final String cropName; // Crop name to be displayed
  final Map<String, dynamic> stageDetails; // The details of the stage from Firestore

  // Constructor to accept stageId, cropName, and stageDetails
  StagewiseDetails({
    required this.stageId,
    required this.cropName,
    required this.stageDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically load the image based on stageId (stage name)
    String formattedCropName = cropName.toLowerCase().replaceAll(" ", "_");
    String formattedStageName = stageId.toLowerCase().replaceAll(" ", "_");
    String imageUrl = 'assets/Growth_Stages/$formattedCropName/$formattedStageName.png';
    print(imageUrl);

    // Convert the stageDetails map to a list of entries and exclude "id"
    List<MapEntry<String, dynamic>> filteredStageDetails = stageDetails.entries
        .where((entry) => entry.key != "id") // Exclude "id" field
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(stageId), // Display stage name as the title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display the image in a fixed-height container
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color to white
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Subtle shadow
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 5), // Shadow position
                    ),
                  ],
                ),
                height: 200, // Fixed height for the image container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FittedBox(
                    fit: BoxFit.cover, // Ensure the image scales without distortion
                    child: Image.asset(
                      imageUrl,
                      width: 600, // Lock the width to maintain proper aspect ratio
                      height: 100, // Match the container height
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
            // Loop through the filtered stage details and display them with proper numbering
            ...filteredStageDetails.asMap().entries.map((entry) {
              int index = entry.key; // Get the index of the entry

              return GestureDetector(
                onTap: () {
                  // Navigate to the new page when a field is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StageFieldDetails(
                        fieldName: entry.value.key,
                        fieldData: entry.value.value,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50, // Light green background for highlighted container
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2), // Border color
                  ),
                  child: Row(
                    children: [
                      // Numbered Circle (0, 1, 2, ...)
                      Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}', // Displaying index number starting from 1
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Field name
                      Expanded(
                        child: Text(
                          entry.value.key, // Field name from Firestore
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Forward arrow icon to navigate to the field details page
                      Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
