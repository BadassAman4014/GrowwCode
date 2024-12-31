import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import '../../FertiliserData/FertiliserData.dart';

class ResultPage extends StatelessWidget {
  final String result;
  final String predictedCrop;

  ResultPage({required this.result, required this.predictedCrop});

  @override
  Widget build(BuildContext context) {
    // Convert the result (Markdown text) to HTML
    String htmlContent = md.markdownToHtml(result);



    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003032), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom AppBar content moved here
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Recommended Crop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 48), // Placeholder to match the AppBar's structure
                  ],
                ),
              ),
              // Image and Predicted Crop Text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/farm.jpg',
                        height: 200.0,
                        width: 400.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          "$predictedCrop",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 80,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // The response wrapped inside a white card
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: Color(0xD9FFFFFF), // White with 60% opacity
                  elevation: 5, // Add shadow to the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: htmlContent, // Use the HTML content derived from Markdown
                          style: {
                            "body": Style(
                              color: Colors.black,
                              fontSize: FontSize(17), // Increased font size by 1 point
                            ),
                            "h1": Style(
                              color: Colors.black,
                              fontSize: FontSize(25), // Increased header font size
                              fontWeight: FontWeight.bold,
                            ),
                            "p": Style(
                              color: Colors.black,
                              fontSize: FontSize(17), // Increased paragraph font size
                            ),
                            "ul": Style(
                              color: Colors.black,
                              fontSize: FontSize(17), // Increased list item font size
                            ),
                            "ol": Style(
                              color: Colors.black,
                              fontSize: FontSize(17), // Increased ordered list font size
                            ),
                            "li": Style(
                              color: Colors.black,
                              fontSize: FontSize(17), // Increased list item font size
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Optional padding for spacing
                child: SizedBox(
                  width: double.infinity, // Make the button take up the full width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FirestoreDataPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'More Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height:10),
            ],
          ),
        ),
      ),
    );
  }
}
