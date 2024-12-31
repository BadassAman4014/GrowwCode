import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class StageFieldDetails extends StatelessWidget {
  final String fieldName;
  final String fieldData;

  StageFieldDetails({required this.fieldName, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fieldName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: fieldData,
                style: {
                  "h2": Style(
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    alignment: Alignment.center,
                  ),
                  "h3": Style(

                    fontSize: FontSize.medium,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                  "ul": Style(
                    listStyleType: ListStyleType.disc,
                    color: Colors.green.shade900,
                  ),
                  "li": Style(
                    color: Colors.black,
                  ),
                  // Apply basic styles to the p tag, but Flutter UI will handle the rest
                  "p": Style(
                    color: Colors.black,
                  ),
                },
              ),

            ],
          ),
        ),
      ),
    );
  }


}
