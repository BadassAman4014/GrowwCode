import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  final String selectedPlantType;
  final Map<String, double> sensorValues;
  final Map<String, Map<String, double>> thresholds;

  ReportPage({
    required this.selectedPlantType,
    required this.sensorValues,
    required this.thresholds,
  });

  // Recommendations for high and low values
  final Map<String, String> highRecommendations = {
    'Moisture': 'Soil moisture is too high. \nReduce irrigation immediately and ensure proper drainage to prevent waterlogging and root diseases.',
    'Temperature': 'Temperature is too high for optimal plant growth. \nIncrease irrigation frequency to cool the soil and consider using shade nets or mulch to reduce heat stress.',
    'Humidity': 'Humidity is too high. \nEnsure good ventilation and airflow around the plants to prevent fungal diseases like powdery mildew or blight.',
    'Nitrogen': 'Nitrogen levels are too high. \nAvoid further nitrogen fertilization to prevent excessive leaf growth at the expense of fruit/seed development.',
    'Phosphorus': 'Phosphorus levels are too high. \nAvoid using phosphorus-rich fertilizers and monitor plant health for signs of nutrient imbalance.',
    'Potassium': 'Potassium levels are too high. \nAvoid applying potassium fertilizers and check for any signs of nutrient deficiencies in plants.',
    'Rainfall': 'Excess rainfall can lead to waterlogged soil. \nEnsure proper drainage and avoid irrigation during periods of heavy rainfall to prevent root diseases.',
  };

  final Map<String, String> lowRecommendations = {
    'Moisture': 'Soil moisture is too low. \nIncrease irrigation or consider drip irrigation to maintain consistent soil moisture levels.',
    'Temperature': 'Temperature is too low. \nUse plastic mulches or row covers to retain soil warmth, especially during cooler seasons or nights.',
    'Humidity': 'Humidity is too low. \nIncrease irrigation and consider misting to maintain higher humidity levels, especially during dry periods.',
    'Nitrogen': 'Nitrogen levels are too low. \nApply a nitrogen-rich fertilizer such as urea or ammonium nitrate to promote healthy plant growth and leaf development.',
    'Phosphorus': 'Phosphorus levels are too low. \nApply phosphorus-rich fertilizers (like superphosphate) to encourage root development and flowering.',
    'Potassium': 'Potassium levels are too low. \nApply a potassium-rich fertilizer, such as potassium sulfate, to support overall plant health and fruit development.',
    'Rainfall': 'Insufficient rainfall. \nImplement an irrigation system to supplement water needs during dry spells and ensure consistent soil moisture.',
  };

  List<Widget> _buildRecommendations() {
    List<Widget> recommendations = [];

    sensorValues.forEach((key, value) {
      final threshold = thresholds[key];
      String recommendation = '';

      if (threshold != null) {
        final minThreshold = threshold['min'] ?? double.negativeInfinity;
        final maxThreshold = threshold['max'] ?? double.infinity;

        if (value < minThreshold) {
          recommendation = _getRecommendationForLow(key);
        } else if (value > maxThreshold) {
          recommendation = _getRecommendationForHigh(key);
        } else {
          recommendation = '$key is within the safe range. Continue current practices.';
        }

        recommendations.add(
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF003032),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child: Text(
                        '$key: ${value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '\n$recommendation',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        recommendations.add(
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'No thresholds available for $key.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    });

    return recommendations;
  }

  String _getRecommendationForHigh(String key) {
    return highRecommendations[key] ?? 'No specific recommendation for $key when values are high.';
  }

  String _getRecommendationForLow(String key) {
    return lowRecommendations[key] ?? 'No specific recommendation for $key when values are low.';
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
        title: Text(
          'Report for $selectedPlantType',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF003032),
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/farm.jpg', // Replace with your image asset
                        height: 180.0,
                        width: 400.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          "$selectedPlantType",
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
              SizedBox(height: 10),
              ..._buildRecommendations(),
            ],
          ),
        ),
      ),
    );
  }
}
