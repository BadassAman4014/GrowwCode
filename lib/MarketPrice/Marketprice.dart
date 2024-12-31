import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listprice.dart';

class MSP extends StatefulWidget {
  @override
  _MSPState createState() => _MSPState();
}

class _MSPState extends State<MSP> {
  late String selectedState;
  late String selectedDistrict;
  late String selectedMarket;

  Map<String, List<String>> stateToDistricts = {
    'Maharashtra': ['Nagpur', 'Thane'],
    'Gujarat': ['Amreli', 'Banaskanth'],
    'Madhya Pradesh': ['Dewas', 'Burhanpur'],
    'Chhattisgarh': ['Burhanpur', 'Balodabazar'],
    'Punjab': ['Bilaspur', 'Ferozpur'],
  };

  Map<String, List<String>> districtToMarkets = {
    'Nagpur': ['Kalmeshwar', 'Hingna'],
    'Thane': ['Amreli', 'Banaskanth'],
    'Amreli': ['Amreli'],
    'Banaskanth': ['Banaskanth'],
    'Dewas': ['Khategaon'],
    'Burhanpur': ['Amreli', 'Sakri'],
    'Balodabazar': ['Some Market'],
    'Bilaspur': ['Some Market'],
    'Ferozpur': ['Some Market'],
  };

  @override
  void initState() {
    super.initState();
    selectedState = 'Maharashtra';
    selectedDistrict = stateToDistricts['Maharashtra']![0];
    selectedMarket = districtToMarkets[selectedDistrict]![0];
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems(List<String> list) {
    return list.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final url =
        "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=579b464db66ec23bdd000001272256ede30145a863893c96a4c022f9&format=json&offset=0&limit=100&filters%5Bstate%5D=$selectedState&filters%5Bdistrict%5D=$selectedDistrict&filters%5Bmarket%5D=$selectedMarket";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['records'] != null) {
        return List<Map<String, dynamic>>.from(data['records']);
      }
    }

    throw Exception('Failed to load data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        title: Text(
          'Market Price',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            _buildDropdown('State', stateToDistricts.keys.toList(), selectedState, (String? newValue) {
              setState(() {
                selectedState = newValue!;
                selectedDistrict = stateToDistricts[selectedState]![0];
                selectedMarket = districtToMarkets[selectedDistrict]![0];
              });
            }),
            SizedBox(height: 20),
            _buildDropdown('District', stateToDistricts[selectedState]!, selectedDistrict, (String? newValue) {
              setState(() {
                selectedDistrict = newValue!;
                selectedMarket = districtToMarkets[selectedDistrict]![0];
              });
            }),
            SizedBox(height: 20),
            _buildDropdown('Market', districtToMarkets[selectedDistrict]!, selectedMarket, (String? newValue) {
              setState(() {
                selectedMarket = newValue!;
              });
            }),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder(
                      future: fetchData(),
                      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoading();
                        } else if (snapshot.hasError) {
                          return _buildError(snapshot.error.toString());
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return MarketDataPage(snapshot.data!);
                        } else {
                          return _buildError('No data available');
                        }
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: Text('View Price', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            onChanged: onChanged,
            isExpanded: true,
            underline: SizedBox(),
            items: buildDropdownMenuItems(items),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blueAccent),
          SizedBox(height: 10),
          Text('Loading data...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }
}
