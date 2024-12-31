import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../AgroGuide/Crop_recommendation/Crop_recommendation_result_page.dart';
import '../AgroGuide/Crop_recommendation/webview.dart';
import '../MarketPrice/Marketprice.dart';
import '../Weather_Forecast/weather_screen.dart';
import 'WeatherCard.dart';

class FarmerSlidingScreens extends StatefulWidget {
  const FarmerSlidingScreens({Key? key}) : super(key: key);

  @override
  _FarmerSlidingScreensState createState() => _FarmerSlidingScreensState();
}

class _FarmerSlidingScreensState extends State<FarmerSlidingScreens> {
  final PageController _controller = PageController(initialPage: 0);
  String? cityName;
  Map<String, dynamic>? weatherData;

  final List<Map<String, dynamic>> _screenImages = [
    {
      'asset': 'assets/upslide/news_placeholder.png',
      'width': 400.0,
      'height': 150.0,
      'isGif': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    getLocationAndFetchWeather();
  }

  Future<void> getLocationAndFetchWeather() async {
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode to get the city name
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          cityName = placemarks.first.locality ?? "Unknown";
        });

        // Fetch weather data for the city
        fetchWeatherData();
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> fetchWeatherData() async {
    if (cityName == null) return;
    String apiUrl =
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$cityName?unitGroup=metric&include=current&key=8W4N7TWVVDAV27TGEZXP2EK9V&contentType=json";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        print("Failed to load weather data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 237.0,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: _screenImages.length + 1, // Include the weather card
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // First card: Weather Info (at index 0)
            if (weatherData == null) {
              // Show loading spinner if data is not yet loaded
              return Center(
                child: Image.asset(
                  'assets/HomePageIcons/placeholder2.gif',
                  width: 380, // Set width and height as needed
                  height: 230,
                ),
              );
            } else {
              // Show weather card when data is available
              return GestureDetector(
                onTap: () {
                  print(index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherScreen(),
                    ),
                  );
                },
                child: WeatherCard(
                  weatherData: weatherData!,
                ),
              );
            }
          } else {
            // Remaining cards: News (adjust index by -1)
            final Map<String, dynamic> imageInfo = _screenImages[index - 1];

            return GestureDetector(
              onTap: () {
                // Navigation based on the index
                if (index == 1) {
                  // News screen (first item in _screenImages)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(url: 'https://www.kisantak.in/'),
                    ),
                  );
                }
                if (index == 2) {
                  // News screen (first item in _screenImages)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MSP(),
                    ),
                  );
                }
              },
              child: Container(
                width: 380.0,
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: imageInfo['isGif']
                      ? Image.asset(
                    imageInfo['asset'],
                    width: imageInfo['width'],
                    height: imageInfo['height'],
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                      : Image.asset(
                    imageInfo['asset'],
                    width: imageInfo['width'],
                    height: imageInfo['height'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
