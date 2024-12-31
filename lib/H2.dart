import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'AddSensor/SensorManagement.dart';
import 'AgroGuide/CropDiseasePrediction/Tflitev2Disease.dart';
import 'AgroGuide/Crop_recommendation/Crop_recommendation.dart';
import 'AgroGuide/Crop_recommendation/webview.dart';
import 'AgroGuide/FeriliserRecommendation/Fertiliser_Recommendation.dart';
import 'AgroGuide/HorizontalMenu.dart';
import 'Chatbot/geminichatbot.dart';
import 'Chatbot/inappbot.dart';
import 'IOT_Monitor/Iot_monitor.dart';
import 'Knowledge_Portal/FertiliserPedia/TEST_CROPSELECTION.dart';
import 'Knowledge_Portal/VikasPedia/VikasPedia.dart';
import 'Profile/ProfilePage.dart';
import 'Slider/TopSlider.dart';
import 'language_provider.dart';
import 'login/language_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Homepage.dart';
import '../language_provider.dart';

class HomeScreen extends StatefulWidget {
  final String language;  // Language passed from the language selection page

  HomeScreen({required this.language});  // Constructor to accept the language

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var user = "Aman Raut";
  var contact = "9021600896";
  List<String> categories = [];
  List<String> trendingCategories = [];
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    print('Selected Language: ${widget.language}'); // Print the selected language
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      fetchData();
    } else {
      print(AppLocalizations.of(context)!.locationPermissionDenied);
    }
  }

  Future<void> fetchData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      String cityName = placemarks.first.locality ?? "Unknown";

      final String apiUrl =
          'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$cityName?unitGroup=metric&include=days%2Ccurrent%2Cevents%2Calerts&key=8W4N7TWVVDAV27TGEZXP2EK9V&contentType=json';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          categories = [
            AppLocalizations.of(context)!.farmingTools,
            AppLocalizations.of(context)!.seedsSaplings,
            AppLocalizations.of(context)!.fertilisers,
            AppLocalizations.of(context)!.gardeningTools,
            AppLocalizations.of(context)!.others,
          ];
          trendingCategories = [
            AppLocalizations.of(context)!.gardeningAccessories,
            AppLocalizations.of(context)!.potashFertiliser,
            AppLocalizations.of(context)!.gardenTower,
            AppLocalizations.of(context)!.allInOneSeedPack,
            AppLocalizations.of(context)!.fertiliser,
          ];
        });
      } else {
        throw Exception(AppLocalizations.of(context)!.failedToLoadWeatherData);
      }
    } catch (e) {
      print('${AppLocalizations.of(context)!.errorFetchingWeatherData}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in the LanguageProvider (if necessary)
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image(
              image: AssetImage('assets/images/logo.jpg'),
              width: 140,
              height: 39,
              fit: BoxFit.cover,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/HomePageIcons/translation.png',
              height: 24,
              width: 24,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LanguageSelectionPage()),
              );
            },
          ),
          SizedBox(width: 15),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FarmerSlidingScreens(),
            Container(
              alignment: Alignment(-0.97, 0), // Numerical alignment values for more specific positioning
              padding: EdgeInsets.only(left: 10.0), // Add padding to the left
              child: Text(
                AppLocalizations.of(context)!.agroGuide, // Dynamic header text
                style: TextStyle(
                  fontSize: 17, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2, // Added letter spacing for visual enhancement
                ),
              ),
            ),
            SizedBox(height: 10),
            HorizontalMenu(
              names: [
                AppLocalizations.of(context)!.iotMonitor,
                AppLocalizations.of(context)!.fertiliserPrediction,
                AppLocalizations.of(context)!.diseasePrediction,
              ],
              images: [
                'assets/HomePageIcons/npk.png',
                'assets/HomePageIcons/fertilizer.png',
                'assets/HomePageIcons/damage.png',
              ],
              onTap: (index) {
                _navigateToAgroguidePage(context, index);
              },
            ),
            SizedBox(height: 10),
            HorizontalMenu(
              names: [
                AppLocalizations.of(context)!.cropSuggestion,
                AppLocalizations.of(context)!.fertiliserPedia,
                AppLocalizations.of(context)!.vikasPedia,
              ],
              images: [
                'assets/HomePageIcons/seeding.png',
                'assets/HomePageIcons/chemical.png',
                'assets/HomePageIcons/informative.png',
              ],
              onTap: (index) {
                _navigateToIOTPage(context, index);
              },
            ),
            UserLocationWidget(), // Include the UserLocationWidget here
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8.0,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        height: 60,
        color: Colors.white70,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(LineIcons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                LineIcons.alternateListAlt,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebViewPage(url: 'https://www.kisantak.in/')),
                );
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: const Icon(
                LineIcons.robot,
                color: Colors.black,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                      child: Container(
                        color: Theme.of(context).canvasColor,
                        height: 200.0,
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[/* Rest of your modal content */],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(
                LineIcons.user,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SensorMaagement()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(
          LineIcons.plus,
          size: 35,
        ),
        elevation: 8.0,
        backgroundColor: Colors.lightGreenAccent,
        foregroundColor: Colors.black,
      ),
    );
  }
}

void _navigateToAgroguidePage(BuildContext context, int index) {
  // Navigate to the respective page based on the category index
  // For simplicity, using a switch statement. You can modify it based on your page navigation logic.
  switch (index) {
    case 0:
      Navigator.push(context, MaterialPageRoute(builder: (context) => SensorDataScreen()));
      break;
    case 1:
      Navigator.push(context, MaterialPageRoute(builder: (context) => FertilizerForm()));
      break;
    case 2:
      Navigator.push(context, MaterialPageRoute(builder: (context) => ObjectDetectionScreen()));
      break;
    default:
      break;
  }
}

void _navigateToIOTPage(BuildContext context, int index) {
  // Navigate to the respective page based on the category index
  // For simplicity, using a switch statement. You can modify it based on your page navigation logic.
  switch (index) {
    case 0:
      Navigator.push(context, MaterialPageRoute(builder: (context) => CropRecommendation()));
      break;
    case 1:
      Navigator.push(context, MaterialPageRoute(builder: (context) => CropSelectionPage()));
      break;
    case 2:
      Navigator.push(context, MaterialPageRoute(builder: (context) => VikaspediaPage(url: 'https://www.myscheme.gov.in/search')));
      break;
    default:
      break;
  }
}

class UserLocationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [],
      ),
    );
  }
}

