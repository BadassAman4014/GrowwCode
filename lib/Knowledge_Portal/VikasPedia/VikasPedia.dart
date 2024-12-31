import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VikaspediaPage extends StatefulWidget {
  final String url;

  const VikaspediaPage({Key? key, required this.url}) : super(key: key);

  @override
  _VikaspediaPageState createState() => _VikaspediaPageState();
}

class _VikaspediaPageState extends State<VikaspediaPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String currentUrl = ''; // Track the current URL

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url; // Set initial URL
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            await _controller.runJavaScript("""
              const element = document.getElementById('contact');
              if (element) {
                element.style.display = 'none'; // Hides the section
              }
            """);
            await _controller.runJavaScript("""
              const navElement = document.querySelector('nav.relative.navbar-expand-lg');
              if (navElement) {
                navElement.style.display = 'none'; // Hides the navbar
              }
            """);

            setState(() {
              _isLoading = false;  // Set loading to false after modifications are done
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(currentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0), // Set the desired height here
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Vikas Pedia",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            elevation: 0.0,
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),  // Add right padding to move the button left
                child: PopupMenuButton<String>(
                  onSelected: (String language) {
                    setState(() {
                      _isLoading = true;

                      if (language == 'English') {
                        currentUrl = 'https://www.myscheme.gov.in/search';
                      } else if (language == 'Hindi') {
                        currentUrl = 'https://www.myscheme.gov.in/hi/search';
                      }

                      _controller.loadRequest(Uri.parse(currentUrl));
                    });

                    Future.delayed(Duration(seconds: 1), () {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },
                  icon: Icon(
                    Icons.language,
                    color: Colors.white,  // Set the icon color to white
                  ),
                  itemBuilder: (BuildContext context) {
                    return {'English', 'Hindi'}.map((String language) {
                      return PopupMenuItem<String>(
                        value: language,
                        child: Text(
                          language,
                          style: TextStyle(color: Colors.black),  // Set the text color to black
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          )
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_isLoading)
                  Center(child: Container(color: Colors.white))  // Show blank page while loading
                else
                  WebViewWidget(controller: _controller),  // Show WebView after loading is complete
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
