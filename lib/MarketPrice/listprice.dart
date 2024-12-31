import 'package:flutter/material.dart';

class MarketDataPage extends StatelessWidget {
  final List<Map<String, dynamic>> marketData;

  MarketDataPage(this.marketData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Market Data',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: marketData.isEmpty
          ? _buildNoData(context)
          : _buildMarketDataList(context),
    );
  }

  Widget _buildMarketDataList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: marketData.length,
        itemBuilder: (context, index) {
          final item = marketData[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['commodity'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Arrival Date: ${item['arrival_date']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Min Price: ₹${item['min_price']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Max Price: ₹${item['max_price']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Modal Price: ₹${item['modal_price']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoData(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 50,
          ),
          SizedBox(height: 20),
          Text(
            'No data available for the selected market.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            label: Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
