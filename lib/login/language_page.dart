import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../H2.dart';
import '../Homepage.dart';
import '../language_provider.dart';

class Language {
  final String name;
  final String code; // Added language code
  final String flagPath;

  Language({required this.name, required this.code, required this.flagPath});
}

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  Language? selectedLanguage;

  final List<Language> languages = [
    Language(name: 'English', code: 'en', flagPath: 'assets/flags/usa.png'),
    Language(name: 'Hindi', code: 'hi', flagPath: 'assets/flags/India.png'),
    Language(name: 'Marathi', code: 'mr', flagPath: 'assets/flags/India.png'),
    Language(name: 'Telugu', code: 'te', flagPath: 'assets/flags/India.png'),
  ];

  void _setLanguageAndNavigate(Language language) {
    // Set the selected language in the provider using the code
    Provider.of<LanguageProvider>(context, listen: false).setLocale(language.code);

    // Debug log to ensure locale is being updated
    print('Locale changed to: ${language.code}');

    // Navigate to the HomeScreen directly with the selected language
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(language: language.name), // Pass the language name
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Language',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(language: '',),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: languages.map((language) {
            return LanguageTile(
              language: language,
              isSelected: selectedLanguage == language,
              onTap: () {
                setState(() {
                  selectedLanguage = language;
                });
                // Directly set the language and navigate
                _setLanguageAndNavigate(language);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    Key? key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? Colors.green.shade100 : Colors.white, // Highlight selected language
        ),
        child: Row(
          children: [
            Image.asset(
              language.flagPath,
              height: 30.0,
              width: 30.0,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                language.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
