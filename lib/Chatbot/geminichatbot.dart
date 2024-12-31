import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../API_Keys/api.dart';

class GeminiChatBot extends StatefulWidget {
  final String botType;

  const GeminiChatBot({Key? key, required this.botType}) : super(key: key);

  @override
  _GeminiChatBotState createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  final textController = TextEditingController();
  RxList<String> chatHistory = <String>[].obs;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "${widget.botType} Bot",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4db151),
        ),
        backgroundColor: Color(0xFFfbfbfb),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chat history (display previous messages)
                      Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          chatHistory.length,
                              (index) => MessageBubble(
                            message: chatHistory[index],
                            isUser: index % 2 == 0,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // User input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      setState(() {
                        isLoading = true;
                      });

                      // Send user input to the chatbot
                      String userMessage = textController.text;
                      String paragraphMessage =
                          "From now on you are a Farmily chatbot... (truncated for brevity)";

                      String botMessage =
                      await GeminiAPI.getGeminiData(paragraphMessage);

                      // Add user and bot messages to the chat history
                      chatHistory.add(userMessage);
                      chatHistory.add(botMessage);

                      // Clear the input field after sending the message
                      textController.clear();

                      setState(() {
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4cb151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    )
                        : Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageBubble(
      {Key? key, required this.message, required this.isUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate widthFactor based on the content length
    double widthFactor =
    (message.length * 10.0 / screenWidth).clamp(0.1, 0.9);

    return Align(
      alignment: isUser ? Alignment.topRight : Alignment.topLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor > 0.4 ? widthFactor : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenWidth * 0.1, // Minimum width set to 20% of screen width
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjust margin values
            padding: EdgeInsets.all(12), // Adjust padding values
            decoration: BoxDecoration(
              color: isUser ? Color(0xFF4cb151) : Color(0xFFe0e0e0), //green : grey
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 10 : 0),
                topRight: Radius.circular(isUser ? 0 : 10),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black, // Set color based on isUser
                fontSize: 14, // Adjust the font size as needed
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    );
  }
}
