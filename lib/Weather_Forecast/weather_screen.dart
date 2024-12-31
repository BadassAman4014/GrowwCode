import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? weatherData;
  String? warning;

  @override
  void initState() {
    // Request notification permission and trigger notification
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    _requestLocationPermission();
    fetchData();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      fetchData();
    } else {
      // Handle case when permission is denied
      print('Location permission denied');

    }
  }

  Future<void> fetchData() async {
    String message= '';
    //location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Use geocoding to get city name from coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    // Extract city name from the first placemark
    String cityName = placemarks.first.locality ?? "";

    try {
      final response = await http.get(Uri.parse(
          'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$cityName?unitGroup=metric&include=days%2Ccurrent%2Cevents%2Calerts&key=8W4N7TWVVDAV27TGEZXP2EK9V&contentType=json'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          message = weatherData!['currentConditions']['conditions'];
          message ='Weather Conditions: $message through out the day';
          print(message);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    triggernotification(message);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBodyBehindAppBar: true,
  //     appBar: AppBar(
  //       backgroundColor: Color(0xFF003032),
  //       leading: IconButton(
  //         icon: Icon(
  //           Icons.arrow_back_ios, // Back arrow icon
  //           color: Colors.white,
  //         ),
  //         onPressed: () {
  //           Navigator.pop(context); // Navigates to the previous screen
  //         },
  //       ),
  //       actions: [
  //         Container(
  //           margin: EdgeInsets.only(right: 16.0),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.refresh, // Refresh icon
  //               color: Colors.white,
  //             ),
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => WeatherScreen(),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //       centerTitle: true,
  //       title: Text(
  //         'Current Weather',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //     body: Stack(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [
  //                 Color(0xFF003032),
  //                 //Color(0xFF003032),
  //                 Color(0xFFFFFFFF),
  //
  //               ],
  //             ),
  //           ),
  //           height: double.infinity,
  //           width: double.infinity,
  //         ),
  //
  //         SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               if (weatherData != null) CurrentWeather(weatherData!['currentConditions']),
  //               _buildHeavyRainWarning(),
  //               // Wrap the forecast widgets in a horizontal scrolling SingleChildScrollView
  //               SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   children: [
  //                     if (weatherData != null) ..._buildForecastWidgets(weatherData!['days']),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Color(0xFF03753C),
  //       leading: IconButton(
  //         icon: Icon(
  //           Icons.arrow_back_ios,
  //           color: Colors.white,
  //         ),
  //         onPressed: () {
  //           Navigator.pop(context); // Navigate to the previous screen
  //         },
  //       ),
  //       actions: [
  //         Container(
  //           margin: EdgeInsets.only(right: 16.0),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.refresh,
  //               color: Colors.white,
  //             ),
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => WeatherScreen(),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //       centerTitle: true,
  //       title: Text(
  //         'Current Weather',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //     body: Stack(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [
  //                 Color(0xFF03753C),
  //                 Color(0xFFFFFFFF),
  //               ],
  //             ),
  //           ),
  //           height: double.infinity,
  //           width: double.infinity,
  //         ),
  //         weatherData == null
  //             ? Center(
  //           child: CircularProgressIndicator(
  //             color: Color(0xFF003032), // Customize color if needed
  //           ),
  //         )
  //             : SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               CurrentWeather(weatherData!['currentConditions']),
  //               _buildHeavyRainWarning(),
  //               SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Row(
  //                   children: [
  //                     if (weatherData != null)
  //                       ..._buildForecastWidgets(weatherData!['days']),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF003032 ),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
            height: double.infinity,
            width: double.infinity,
          ),
          // Custom AppBar Content
          Positioned(
            top: 40, // Adjust based on safe area
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Navigate to the previous screen
                  },
                ),
                // Title
                Text(
                  'Current Weather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Refresh Button
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Main Body Content
          Positioned.fill(
            top: 100, // Adjust to leave space for the custom appbar
            child: weatherData == null
                ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF003032), // Customize color if needed
              ),
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  CurrentWeather(weatherData!['currentConditions']),
                  _buildHeavyRainWarning(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (weatherData != null)
                          ..._buildForecastWidgets(weatherData!['days']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeavyRainWarning() {
    if (weatherData != null) {
      double precipProbability = weatherData!['currentConditions']['precipprob'];
      String weatherDescription = weatherData!['currentConditions']['conditions'];

      if (precipProbability > 50.0) {
        warning = 'Heavy rain is forecasted in the upcoming days. Please stay informed and take necessary precautions.';
        triggernotification(warning!);
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              width: 350,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heavy rain is forecasted in the upcoming days. Please stay informed and take necessary precautions.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '⚠️ Heavy Rain Warning',
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
            ),
            SizedBox(height: 10),
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              width: 350,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Day for Irrigation',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Weather Conditions: $weatherDescription through out the day',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '👌 No Warnings',
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
            ),
            SizedBox(height: 10),
          ],
        );
      }
    } else {
      // Return a default widget or loading indicator when weatherData is null
      return CircularProgressIndicator();
    }
  }



  List<Widget> _buildForecastWidgets(List<dynamic> forecast) {
    List<Widget> widgets = [];

    for (int i = 0; i < forecast.length; i += 2) {
      if (i + 1 < forecast.length) {
        widgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildForecastItem(forecast[i]),
              _buildForecastItem(forecast[i + 1]),
            ],
          ),
        );
      } else {
        widgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildForecastItem(forecast[i]),
            ],
          ),
        );
      }
    }

    return widgets;
  }


  // Widget _buildForecastItem(Map<String, dynamic> day) {
  //   DateTime dateTime = DateTime.parse(day['datetime']);
  //   String formattedDate = DateFormat('dd MMM').format(dateTime);
  //
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
  //     padding: EdgeInsets.all(10),
  //     height: 170,
  //     width: 190,
  //     child: Stack(
  //       children: [
  //         Image.asset(
  //           'assets/upslide/vector_bg.png',
  //           width: 200,
  //           height: 200,
  //         ),
  //         // Column(
  //         //   crossAxisAlignment: CrossAxisAlignment.start,
  //         //   children: [
  //         //     SizedBox(height: 10),
  //         //     Text(
  //         //       '♨️ : ${day['humidity']}%',
  //         //       style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  //         //     ),
  //         //   ],
  //         // ),
  //         Positioned(
  //           top: -4,
  //           right: 4,
  //           child: Image.asset(
  //             'assets/upslide/sun.png',
  //             width: 80,
  //             height: 80,
  //           ),
  //         ),
  //         Positioned(
  //           top: 20,
  //           left: 12,
  //           child: Text(
  //             '${day['tempmax']}°',
  //             style: TextStyle(
  //               fontSize: 22,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF015f65), // Set your desired color here
  //             ),
  //           ),
  //         ),
  //
  //         Positioned(
  //           bottom: 40,
  //           left: 12,
  //           child: Text(
  //             '${day['conditions']}',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFF015f65), // Set your desired color here
  //             ),
  //           ),
  //         ),
  //
  //         Positioned(
  //           top: 50,
  //           left: 15,
  //           child: Text(
  //             formattedDate, // Display the date here
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black54, // Set your desired color here
  //             ),
  //           ),
  //         )
  //
  //
  //       ],
  //     ),
  //   );
  // }

  Widget _buildForecastItem(Map<String, dynamic> day) {
    DateTime dateTime = DateTime.parse(day['datetime']);
    String formattedDate = DateFormat('dd MMM').format(dateTime);

    // Get the icon name from the API data
    String iconName = day['icon'];
    String iconPath = _getWeatherImage(iconName);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      padding: EdgeInsets.all(10),
      height: 170,
      width: 190,
      child: Stack(
        children: [
          Image.asset(
            'assets/upslide/vector_bg.png',
            width: 200,
            height: 200,
          ),
          Positioned(
            top: -4,
            right: 4,
            child: Image.asset(
              iconPath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 20,
            left: 12,
            child: Text(
              '${day['tempmax']}°',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF015f65),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 12,
            child: Text(
              '${day['conditions']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF015f65),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 15,
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _getWeatherImage(String iconName) {
  switch (iconName) {
    case 'clear':
      return 'assets/weather_icons/clear-day.png';
    case 'clear-night':
      return 'assets/weather_icons/clear-day.png';
    case 'rain':
      return 'assets/weather_icons/rain.png';
    case 'snow':
      return 'assets/weather_icons/snow.png';
    case 'sleet':
      return 'assets/weather_icons/default.png';
    case 'wind':
      return 'assets/weather_icons/wind.png';
    case 'fog':
      return 'assets/weather_icons/fog.png';
    case 'cloudy':
      return 'assets/weather_icons/cloudy.png';
    case 'partly-cloudy-day':
      return 'assets/weather_icons/cloudy.png';
    case 'partly-cloudy-night':
      return 'assets/weather_icons/cloudy.png';
    case 'hail':
      return 'assets/weather_icons/hail.png';
    case 'thunderstorm':
      return 'assets/weather_icons/thunderstorm.png';
    case 'tornado':
      return 'assets/weather_icons/default.png';
    default:
      return 'assets/weather_icons/clear_day.png'; // Default image for unknown conditions
  }
}

class CurrentWeather extends StatelessWidget {
  final Map<String, dynamic> currentConditions;

  CurrentWeather(this.currentConditions);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.fromLTRB(16, 10, 16, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: Colors.transparent,
      child: Container(
        height: 250,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFfbfbfb),
              Color(0xFFfbfbfb),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherInfoItem(WeatherIcons.thermometer, 'Temperature', '${currentConditions['temp']}°C', Color(0xFF015f65)),
                  _buildWeatherInfoItem(WeatherIcons.humidity, 'Humidity', '${currentConditions['humidity']}°C', Color(0xFF015f65)),
                  _buildWeatherInfoItem(WeatherIcons.rain, 'Rain Chance', '${currentConditions['precipprob']}%', Color(0xFF015f65)),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherInfoItem(WeatherIcons.day_windy, 'WindSpeed', '${currentConditions['windspeed']} km/h', Color(0xFF015f65)),
                  _buildWeatherInfoItem(WeatherIcons.sunrise, 'Sunrise', '${currentConditions['sunrise']}', Color(0xFF015f65)),
                  _buildWeatherInfoItem(WeatherIcons.sunset, 'Sunset', '${currentConditions['sunset']}', Color(0xFF015f65)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(IconData icon, String title, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 30, color: iconColor),
        SizedBox(height: 13),
        Text(
          value,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

void triggernotification(String Message) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'AgroGuide',
      body: Message, // Use the passed argument here
    ),
  );
}