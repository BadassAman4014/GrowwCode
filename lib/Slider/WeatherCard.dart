import 'package:flutter/material.dart';
import '../Weather_Forecast/weather_screen.dart';
import '../API_Keys/api.dart'; // Ensure you have the GeminiAPI imported.

import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  final Map<String, dynamic>? weatherData;

  WeatherCard({required this.weatherData});

  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String? geminiOutput;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGeminiOutput();
  }

  Future<void> fetchGeminiOutput() async {
    if (widget.weatherData != null) {
      // Safely extract parameters with default values if null
      String temperature = "${widget.weatherData!['days'][0]['temp'] ?? 'N/A'}°C";
      String humidity = "${widget.weatherData!['days'][0]['humidity'] ?? 'N/A'}%";
      String precipitation = "${widget.weatherData!['days'][0]['precip'] ?? 'N/A'}mm";
      String windSpeed = "${widget.weatherData!['days'][0]['windspeed'] ?? 'N/A'} km/h";
      String solarRadiation = "${widget.weatherData!['days'][0]['solarradiation'] ?? 'N/A'} W/m²";
      String uvIndex = "${widget.weatherData!['days'][0]['uvindex'] ?? 'N/A'}";

      // Gemini prompt
      String prompt =
          "Generate a concise, 5-word (or fewer) actionable insight for farmers related to fertiliser and irrigation planning. The temperature is $temperature, humidity is $humidity, precipitation is $precipitation. "
          "Summarize the day in 2 lines (strictly 5-6 words each): "
          "🟢 First line: Positive farming insight. "
          "🔴 Second line: Warning or caution related to farming.";

      try {
        String response = await GeminiAPI.getGeminiData(prompt);
        setState(() {
          geminiOutput = response;
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          geminiOutput = "Error fetching Gemini output.";
          isLoading = false;
        });
      }
    }
  }

  IconData getWeatherIcon(String apiIcon) {
    switch (apiIcon) {
      case 'clear-day':
        return Icons.wb_sunny;
      case 'clear-night':
        return Icons.nights_stay;
      case 'rain':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      case 'sleet':
        return Icons.grain;
      case 'wind':
        return Icons.air;
      case 'fog':
        return Icons.foggy;
      case 'cloudy':
        return Icons.cloud;
      case 'partly-cloudy-day':
        return Icons.wb_cloudy;
      case 'partly-cloudy-night':
        return Icons.cloud;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weatherData == null || widget.weatherData!.isEmpty) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Weather data is loading. Please wait!")),
          );
        },
        child: _buildWeatherCard(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeatherScreen()),
          );
        },
        child: _buildWeatherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationInfo(),
              WeatherForecastSlider(widget.weatherData!['days']),
              Divider(color: Colors.white54, thickness: 2),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : _buildGeminiOutput(),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildWeatherCard({required Widget child}) {
    return Card(
      color: Colors.blue.shade400,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: SizedBox(
        width: 450,
        height: 193,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.white),
        SizedBox(width: 8),
        Text(
          widget.weatherData!['resolvedAddress'] ?? 'Unknown Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGeminiOutput() {
    return Text(
      geminiOutput ?? "No data available.",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}

class WeatherForecastSlider extends StatelessWidget {
  final List<dynamic> forecast;

  WeatherForecastSlider(this.forecast);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildForecastWidgets(forecast),
      ),
    );
  }

  List<Widget> _buildForecastWidgets(List<dynamic> forecast) {
    List<Widget> widgets = [];

    for (int i = 0; i < forecast.length; i++) {
      widgets.add(_buildForecastItem(forecast[i]));
    }

    return widgets;
  }

  Widget _buildForecastItem(Map<String, dynamic> day) {
    DateTime dateTime = DateTime.parse(day['datetime']);
    String formattedDate = DateFormat('dd MMM').format(dateTime);

    String iconName = day['icon'] ?? 'clear-day'; // Default to 'clear-day' if no icon
    String iconPath = _getWeatherImage(iconName);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5), // Reduced margin
      padding: EdgeInsets.all(5), // Reduced padding
      height: 100, // Reduced height
      width: 120, // Reduced width
      child: Stack(
        children: [
          Image.asset(
            'assets/upslide/vector_bg.png',
            width: 130, // Adjusted width
            height: 130, // Adjusted height
          ),
          Positioned(
            right: 10,
            child: Image.asset(
              iconPath,
              width: 40, // Reduced icon size
              height: 40, // Reduced icon size
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 10,
            left: 8,
            child: Text(
              '${day['tempmax']}°',
              style: TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Color(0xFF015f65),
              ),
            ),
          ),
          Positioned(
            bottom: 22, // Adjusted position of the condition text
            left: 8,
            child: Text(
              '${day['conditions']}',
              style: TextStyle(
                fontSize: 11, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Color(0xFF015f65),
              ),
            ),
          ),
          Positioned(
            top: 30, // Adjusted position of the date text
            left: 10,
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 8, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
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
}
