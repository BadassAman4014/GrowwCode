import 'package:flutter/material.dart';
import '../../API_Keys/api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

class PredictionResultPage extends StatefulWidget {
  final String crop;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String temperature;
  final String humidity;
  final String moisture;
  final String ph;
  final String rainfall;
  final String landAcres;
  final String plantStage;
  final String location;

  const PredictionResultPage({
    Key? key,
    required this.crop,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.ph,
    required this.rainfall,
    required this.landAcres,
    required this.plantStage,
    required this.location,
  }) : super(key: key);

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {
  String _chemicalApiResponse = '';
  String _organicApiResponse = '';
  String _hybridApiResponse = ''; // For hybrid fertilizer
  bool _isLoading = true;
  String _selectedLanguage = 'English'; // Default language

  final Map<String, String> cropImages = {
    'Wheat': 'assets/FertiliserRecommCrops/wheat.jpg',
    'Rice': 'assets/FertiliserRecommCrops/rice.jpeg',
    'Sugarcane': 'assets/FertiliserRecommCrops/sugarcane_placeholder.jpg',
    'Maize': 'assets/FertiliserRecommCrops/maize.jpeg',
  };

  final Map<String, Map<String, String>> languageStrings = {
    'English': {
      'predictionResults': 'Prediction Results',
      'crop': 'Crop',
      'plantStage': 'Plant Stage',
      'location': 'Location',
      'chemicalFertilizer': 'Chemical Fertilizer Suggestion',
      'organicFertilizer': 'Organic Fertilizer Suggestion',
      'hybridFertilizer': 'Hybrid Fertilizer Suggestion', // New entry for Hybrid Fertilizer
      'fertilizerDetails': 'Fertilizer Details',
    },
    'Hindi': {
      'predictionResults': 'पूर्वानुमान परिणाम',
      'crop': 'फसल',
      'plantStage': 'पौधे का चरण',
      'location': 'स्थान',
      'chemicalFertilizer': 'रासायनिक उर्वरक सुझाव',
      'organicFertilizer': 'जैविक उर्वरक सुझाव',
      'hybridFertilizer': 'हाइब्रिड उर्वरक सुझाव', // New entry for Hybrid Fertilizer
      'fertilizerDetails': 'उर्वरक विवरण',
    },
    'Telugu': {
      'predictionResults': 'ప్రమాణాల ఫలితాలు',
      'crop': 'పంట',
      'plantStage': 'పంట దశ',
      'location': 'స్థలం',
      'chemicalFertilizer': 'రసాయనిక ఎరువు సూచన',
      'organicFertilizer': 'ఆర్గానిక్ ఎరువు సూచన',
      'hybridFertilizer': 'హైబ్రిడ్ ఎరువు సూచన', // New entry for Hybrid Fertilizer
      'fertilizerDetails': 'ఎరువు వివరాలు',
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchFertilizerRecommendations();
  }

  // Fetch translations dynamically based on the selected language
  String getTranslatedText(String key) {
    return languageStrings[_selectedLanguage]?[key] ?? key; // Default to key if translation is missing
  }

  Future<void> _fetchFertilizerRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    String message = '''
    In $_selectedLanguage show me detailed suggestions.
    Consider yourself an expert agricultural guide. Suggest fertilizer plans based on these inputs:
    - Crop: ${widget.crop}
    - Land Area: ${widget.landAcres} acres
    - Plant Stage: ${widget.plantStage}
    - Location: ${widget.location}
    - Soil and Environmental Data:
      - Nitrogen: ${widget.nitrogen} kg/ha
      - Phosphorus: ${widget.phosphorus} kg/ha
      - Potassium: ${widget.potassium} kg/ha
      - Temperature: ${widget.temperature}°C
      - Humidity: ${widget.humidity}%
      - Moisture: ${widget.moisture}%
      - pH: ${widget.ph}
      - Rainfall: ${widget.rainfall} mm
    Provide specific fertilizer recommendations, including the names of fertilizers available in the market, their implementation schedules, and justifications for the recommendations.  
    Also Provide me average indian market prices of fertiliser which can be used to reduce the lack of nutrient in Soil.
    Additionally, explain the implications of:  
    1. Excessive use of fertilizers.   
    2. Insufficient use or complete omission of fertilizers   
    Ensure the response is detailed and practical.  
    
    Also provide indian document refrences as well
    ''';

    try {
      // Fetching chemical fertilizer recommendation
      String chemicalResponse = await GeminiAPI.getGeminiData(message);
      setState(() {
        _chemicalApiResponse = chemicalResponse.isNotEmpty ? chemicalResponse : 'No data received from the API.';
      });

      // Fetching organic fertilizer recommendation
      String organicMessage = '''
      In $_selectedLanguage show me the organic suggestions.
      Suggest organic fertilizer recommendations based on these inputs:
      - Crop: ${widget.crop}
      - Land Area: ${widget.landAcres} acres
      - Plant Stage: ${widget.plantStage}
      - Location: ${widget.location}
      - Soil and Environmental Data:
        - Nitrogen: ${widget.nitrogen} kg/ha
        - Phosphorus: ${widget.phosphorus} kg/ha
        - Potassium: ${widget.potassium} kg/ha
        - Temperature: ${widget.temperature}°C
        - Humidity: ${widget.humidity}%
        - Moisture: ${widget.moisture}%
        - pH: ${widget.ph}
        - Rainfall: ${widget.rainfall} mm
      Provide specific organic fertilizer recommendations, including names of fertilizers, schedules, and justifications.  
      Also Provide me average indian market prices of fertiliser which can be used to reduce the lack of nutrient in Soil.
      Additionally, explain the implications of:  
      1. Excessive use of organic fertilizers.   
      2. Insufficient or omission of organic fertilizers. 
      
      Ensure the response is detailed and practical.
      Also provide indian document refrences as well
      ''';

      String organicResponse = await GeminiAPI.getGeminiData(organicMessage);
      setState(() {
        _organicApiResponse = organicResponse.isNotEmpty ? organicResponse : 'No data received from the API.';
      });

// Fetching bio-organic fertilizer recommendation
      String hybridMessage = '''
        In $_selectedLanguage, show me the bio-organic fertilizer suggestions.  
        Suggest bio-organic fertilizer recommendations based on these inputs:  
        - Crop: ${widget.crop}  
        - Land Area: ${widget.landAcres} acres  
        - Plant Stage: ${widget.plantStage}  
        - Location: ${widget.location}  
        - Soil and Environmental Data:  
          - Nitrogen: ${widget.nitrogen} kg/ha  
          - Phosphorus: ${widget.phosphorus} kg/ha  
          - Potassium: ${widget.potassium} kg/ha  
          - Temperature: ${widget.temperature}°C  
          - Humidity: ${widget.humidity}%  
          - Moisture: ${widget.moisture}%  
          - pH: ${widget.ph}  
          - Rainfall: ${widget.rainfall} mm  
        
        Provide specific recommendations for bio-organic and composite fertilizers, incorporating combinations of organic and chemical fertilizers. Include:  
        - The names of fertilizers (e.g., bio-organic composts, enriched manures, and compatible chemical supplements).  
        - Application schedules and dosages tailored to the above inputs.  
        - Justifications for each recommendation, including how they address the soil and crop needs.  
        
        Additionally, provide the average indian market prices of the recommended fertilizers and outline cost-effective strategies to balance nutrient deficiencies in the soil.  
        
        Explain the implications of:  
        1. Excessive use of chemical supplements in bio-organic combinations.  
        2. Insufficient or omission of bio-organic fertilizers in soil management.  
        3. Benefits of integrating bio-organic practices with chemical approaches for long-term soil health and crop yield.  
        
        Ensure the response is detailed and practical.
        Also provide indian document refrences as well
        ''';


      String hybridResponse = await GeminiAPI.getGeminiData(hybridMessage);
      setState(() {
        _hybridApiResponse = hybridResponse.isNotEmpty ? hybridResponse : 'No data received from the API.';
      });
    } catch (e) {
      setState(() {
        _chemicalApiResponse = 'Failed to fetch data: $e';
        _organicApiResponse = 'Failed to fetch organic fertilizer data: $e';
        _hybridApiResponse = 'Failed to fetch hybrid fertilizer data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _processMarkdown(String input) {
    return md.markdownToHtml(input);
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = cropImages[widget.crop] ?? 'assets/images/default_crop.jpg';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,  // Align title to the left
          children: [
            Text(
              getTranslatedText('predictionResults'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: false,  // Prevent title from being centered
        actions: [
          // Dropdown for language selection with dynamic behavior
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.green,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
                // Reload the page or handle the language change here
                _fetchFertilizerRecommendations(); // Fetch new recommendations based on the selected language
              },
              items: <String>['English', 'Hindi', 'Telugu']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.black)), // Language names in black
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  imagePath,
                  height: 200.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                getTranslatedText('crop') + ': ${widget.crop}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                getTranslatedText('plantStage') + ': ${widget.plantStage}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                getTranslatedText('location') + ': ${widget.location}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Chemical Fertilizer Recommendations
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      getTranslatedText('chemicalFertilizer'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Html(
                            data: _processMarkdown(_chemicalApiResponse),
                            style: {
                              "body": Style(
                                  fontSize: FontSize.large, lineHeight: LineHeight(1.6)),
                              "h1": Style(
                                  fontSize: FontSize.xLarge, fontWeight: FontWeight.bold),
                              "h2": Style(
                                  fontSize: FontSize.large, fontWeight: FontWeight.bold),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Organic Fertilizer Recommendations
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      getTranslatedText('organicFertilizer'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Html(
                            data: _processMarkdown(_organicApiResponse),
                            style: {
                              "body": Style(
                                  fontSize: FontSize.large, lineHeight: LineHeight(1.6)),
                              "h1": Style(
                                  fontSize: FontSize.xLarge, fontWeight: FontWeight.bold),
                              "h2": Style(
                                  fontSize: FontSize.large, fontWeight: FontWeight.bold),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hybrid Fertilizer Recommendations
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      getTranslatedText('hybridFertilizer'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Html(
                            data: _processMarkdown(_hybridApiResponse),
                            style: {
                              "body": Style(
                                  fontSize: FontSize.large, lineHeight: LineHeight(1.6)),
                              "h1": Style(
                                  fontSize: FontSize.xLarge, fontWeight: FontWeight.bold),
                              "h2": Style(
                                  fontSize: FontSize.large, fontWeight: FontWeight.bold),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
