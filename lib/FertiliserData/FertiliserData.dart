import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';

class FirestoreDataPage extends StatefulWidget {
  @override
  _FirestoreDataPageState createState() => _FirestoreDataPageState();
}

class _FirestoreDataPageState extends State<FirestoreDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? cropData;
  bool isLoading = true;
  String? errorMessage;
  String selectedCrop = 'Wheat';

  final List<Map<String, String>> crops = [
    {'name': 'Wheat', 'icon': 'assets/icons/wheat.png'},
    {'name': 'Cotton', 'icon': 'assets/icons/cotton.png'},
    {'name': 'Orange', 'icon': 'assets/icons/orange.png'},
    {'name': 'SugarCane', 'icon': 'assets/icons/sugarcane.png'},
    {'name': 'Potato', 'icon': 'assets/icons/potato.png'},
    {'name': 'Oats', 'icon': 'assets/icons/oats.png'},
    {'name': 'Soybean', 'icon': 'assets/icons/soybean.png'},
    {'name': 'Sugarcane', 'icon': 'assets/icons/sugarcane.png'},
  ];

  @override
  void initState() {
    super.initState();
    fetchData(selectedCrop);
  }

  Future<void> fetchData(String crop) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    int retryCount = 0;
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        DocumentSnapshot doc =
        await _firestore.collection('FeritiliserData').doc(crop).get();

        if (doc.exists) {
          setState(() {
            cropData = doc.data() as Map<String, dynamic>?;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Document for $crop does not exist.";
            isLoading = false;
          });
        }
        return;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          setState(() {
            errorMessage = "Max retries reached. Could not fetch data.";
            isLoading = false;
          });
          break;
        }
        await Future.delayed(retryDelay * retryCount);
      }
    }
  }

  // Method to show modal bottom sheet
  void _showModalBottomSheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView( // Makes the content scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Html(
                  data: content,
                  style: {
                    "body": Style(
                      fontSize: FontSize.medium,
                    ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
      ),
      body: Column(
        children: [
          Container(
            height: 110,
            padding: EdgeInsets.only(top: 4.0, bottom: 0.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCrop = crop['name']!;
                    });
                    fetchData(selectedCrop);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(crop['icon']!),
                          radius: 40,
                          backgroundColor: selectedCrop == crop['name']
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                        ),
                        SizedBox(height: 5),
                        Text(
                          crop['name']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: selectedCrop == crop['name']
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: cropData!.entries.length,
                itemBuilder: (context, index) {
                  var entry = cropData!.entries.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      // Show modal bottom sheet when tapped
                      _showModalBottomSheet(entry.key, entry.value.toString());
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        trailing: Icon(Icons.info_outline),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
