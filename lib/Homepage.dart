// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:line_icons/line_icons.dart';
// import 'AddSensor/SensorManagement.dart';
// import 'AgroGuide/CropDiseasePrediction/Tflitev2Disease.dart';
// import 'AgroGuide/Crop_recommendation/Crop_recommendation.dart';
// import 'AgroGuide/Crop_recommendation/webview.dart';
// import 'AgroGuide/FeriliserRecommendation/Fertiliser_Recommendation.dart';
// import 'AgroGuide/HorizontalMenu.dart';
// import 'Chatbot/geminichatbot.dart';
// import 'Chatbot/inappbot.dart';
// import 'IOT_Monitor/Iot_monitor.dart';
// import 'Knowledge_Portal/FertiliserPedia/TEST_CROPSELECTION.dart';
// import 'Knowledge_Portal/VikasPedia/VikasPedia.dart';
// import 'Profile/ProfilePage.dart';
// import 'Slider/TopSlider.dart';
// import 'login/language_page.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   var user = "Aman Raut";
//   var contact = "9021600896";
//   List<String> categories = ['Farming Tools', 'Seeds & Saplings', 'Fertilisers', 'Gardening Tools', 'Others'];
//   List<String> Trendingcategories = ['Gardening  \nAccessories', 'Potash  \nFertiliser', 'Garden Tower', 'All In Once\n Seed Pack', 'Fertiliser'];
//   Map<String, dynamic>? weatherData;
//   String? warning;
//   ValueNotifier<bool> isDialOpen = ValueNotifier(false);
//   bool customDialRoot = true;
//   bool extend = false;
//   bool rmIcons = false;
//   get http => null;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestLocationPermission();
//     fetchData();
//   }
//
//   Future<void> _requestLocationPermission() async {
//     var status = await Permission.location.request();
//     if (status == PermissionStatus.granted) {
//       fetchData();
//     } else {
//       // Handle case when permission is denied
//       print('Location permission denied');
//     }
//   }
//
//   Future<void> fetchData() async {
//     String message = '';
//     try {
//       // Get current position
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//
//       // Get city name from coordinates using geocoding
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//           position.latitude, position.longitude);
//
//       String cityName = placemarks.first.locality ?? "Unknown";
//
//       // API call to fetch weather data using the city name
//       final String apiUrl =
//           'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$cityName?unitGroup=metric&include=days%2Ccurrent%2Cevents%2Calerts&key=8W4N7TWVVDAV27TGEZXP2EK9V&contentType=json';
//       final response = await http.get(Uri.parse(apiUrl));
//
//       if (response.statusCode == 200) {
//         setState(() {
//           // Parse JSON response
//           weatherData = json.decode(response.body);
//
//           // Extract and print current conditions
//           String currentCondition = weatherData!['currentConditions']['conditions'];
//           message = 'Weather Conditions: $currentCondition throughout the day';
//
//           print(message);
//         });
//       } else {
//         // Handle error if response status is not 200
//         throw Exception('Failed to load weather data');
//       }
//     } catch (e) {
//       // Handle exceptions like permission issues, API errors, or JSON parsing errors
//       print('Error fetching weather data: $e');
//     }
//
//     // Optionally trigger notification or update UI with weather message
//     // triggerNotification(message);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the start (left)
//           children: [
//             Image(
//               image: AssetImage('assets/images/logo.jpg'),
//               width: 140,  // Set the desired width
//               height: 39, // Set the desired height
//               fit: BoxFit.cover, // Adjust the fit as needed
//             ),
//           ],
//         ),
//
//         actions: [
//           IconButton(
//             icon: Image.asset(
//               'assets/HomePageIcons/translation.png', // Path to your image file
//               height: 24, // Adjust the size as needed
//               width: 24,
//             ),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => LanguageSelectionPage()),
//               );
//             },
//           ),
//           SizedBox(width: 15),
//         ],
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FarmerSlidingScreens(),
//             SizedBox(height: 10),
//             Container(
//               alignment: Alignment(-0.97, 0), // Numerical alignment values for more specific positioning
//               padding: EdgeInsets.only(left: 10.0), // Add padding to the left
//               child: Text(
//                 "AgroGuide", // Dynamic header text
//                 style: TextStyle(
//                   fontSize: 17, // Adjusted font size
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2, // Added letter spacing for visual enhancement
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 10),
//             HorizontalMenu(
//               names: [
//                 'IOT Monitor',
//                 'Fertiliser\nSuggestion',
//                 'Disease\nPrediction',
//               ],
//               images: [
//                 'assets/HomePageIcons/npk.png',
//                 'assets/HomePageIcons/fertilizer.png',
//                 'assets/HomePageIcons/damage.png',
//               ],
//               onTap: (index) {
//                 _navigateToAgroguidePage(context, index);
//               },
//             ),
//           SizedBox(height: 10),
//             HorizontalMenu(
//               names: [
//                 'Crop\nSuggestion',
//                 'Fertiliser Pedia',
//                 'VikasPedia',
//               ],
//               images: [
//                 'assets/HomePageIcons/seeding.png',
//                 'assets/HomePageIcons/chemical.png',
//                 'assets/HomePageIcons/informative.png',
//               ],
//               onTap: (index) {
//                 _navigateToIOTPage(context, index);
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         elevation: 8.0,
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         height: 60,
//         color: Colors.white70,
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 5,
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             IconButton(
//               icon: Icon(LineIcons.home),  // Create an instance of Icon and pass LineIcons.home
//               onPressed: () {
//               },
//             ),
//             IconButton(
//               icon: const Icon(
//                 LineIcons.alternateListAlt,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   // MaterialPageRoute(builder: (context) => FirestoreDataPage()), // Replace CartPage with the actual name of your cart page class
//                   MaterialPageRoute(builder: (context) => WebViewPage(url: 'https://www.kisantak.in/')), // Replace CartPage with the actual name of your cart page class
//                 );
//               },
//             ),
//
//             SizedBox(width: 40),
//
//             IconButton(
//               icon: const Icon(
//                 LineIcons.robot,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return ClipRRect(
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//                       child: Container(
//                         color: Theme.of(context).canvasColor,
//                         height: 200.0, // Adjusted height for better spacing
//                         child: Stack(
//                           children: [
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 // Heading for the pop-up with adjusted padding
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.chat,
//                                         color: Colors.green, // Set the desired color
//                                         size: 24.0, // Set the desired size
//                                       ),
//                                       SizedBox(width: 8.0), // Add some space between the icon and text
//                                       Text(
//                                         'Select Assistance Type',
//                                         style: TextStyle(
//                                           fontSize: 18.0,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Divider(
//                                   // Add a Divider below the text
//                                   color: Colors.black26,
//                                   thickness: 1.0,
//                                   height: 40.0,
//                                 ),
//                                 Row(
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: ListTile(
//                                         contentPadding: EdgeInsets.all(8.0),
//                                         leading: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Icon(
//                                             Icons.support_agent_rounded,
//                                             color: Colors.green, // Set the desired color
//                                           ),
//                                         ),
//                                         title: const Text('Chat 1'),
//                                         subtitle: const Text('General ChatBot'),
//                                         onTap: () {
//                                           Navigator.pop(context);
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => const GeminiChatBot(botType: 'Family'),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: ListTile(
//                                         contentPadding: EdgeInsets.all(8.0),
//                                         leading: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Icon(
//                                             Icons.phonelink_setup_rounded,
//                                             color: Colors.green, // Set the desired color
//                                           ),
//                                         ),
//                                         title: const Text('Chat 2'),
//                                         subtitle: const Text('In App Support'),
//                                         onTap: () {
//                                           Navigator.pop(context);
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) => const InAppBot(botType: 'InAPP'),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Positioned(
//                               top: 8.0,
//                               right: 16.0,
//                               child: IconButton(
//                                 icon: Icon(Icons.close),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(
//                 LineIcons.user,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ProfilePage()), // Replace CartPage with the actual name of your cart page class
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Dock FAB to center of BottomAppBar
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SensorMaagement()), // Replace CartPage with the actual name of your cart page class
//           );
//           // Your FAB action here
//         },
//         shape: const CircleBorder(), // Ensures a perfectly circular shape
//         child: const Icon(
//           LineIcons.plus,
//           size: 35, // Adjust the size of the icon if needed
//         ),
//         elevation: 8.0, // Customize elevation for a better shadow effect
//         backgroundColor: Colors.lightGreenAccent, // Customize the background color
//         foregroundColor: Colors.black, // Icon color
//       ),
//     );
//   }
// }
//
// void _navigateToAgroguidePage(BuildContext context, int index) {
//   // Navigate to the respective page based on the category index
//   // For simplicity, using a switch statement. You can modify it based on your page navigation logic.
//   switch (index) {
//     case 0:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => SensorDataScreen()));
//       break;
//     case 1:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => FertilizerForm()));
//       break;
//     case 2:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectionScreen()));
//       break;
//     default:
//       break;
//   }
// }
//
// void _navigateToIOTPage(BuildContext context, int index) {
//   // Navigate to the respective page based on the category index
//   // For simplicity, using a switch statement. You can modify it based on your page navigation logic.
//   switch (index) {
//     case 0:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => CropRecommendation()));
//       break;
//     case 1:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => CropSelectionPage()));
//       break;
//     case 2:
//       Navigator.push(context, MaterialPageRoute(builder: (context) => VikaspediaPage(url: 'https://www.myscheme.gov.in/search')));
//       break;
//     default:
//       break;
//   }
// }
//
// class UserLocationWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center( // Center-aligns the Row widget
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center, // Center the contents horizontally
//         children: [
//           Icon(
//             Icons.location_on, // Location icon
//             color: Colors.black, // Icon color
//             size: 20, // Icon size
//           ),
//           SizedBox(width: 8), // Adds space between the icon and the text
//           Text(
//             'Wanadongri, Nagpur',
//             style: TextStyle(fontSize: 16, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
