import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context); // Pop the current route
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("FAQs"),
          backgroundColor: Colors.teal.shade300,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildFaqQuestion("Credits"),
              _buildFaqAnswer(
                  "SWD Nucleus - Opportunity and Guidance in making the app\nRiddhi Chatterjee - App Testing\nAryan Dalmia - App Development"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqQuestion(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildFaqAnswer(String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(answer, style: TextStyle(fontSize: 16)),
    );
  }
}
