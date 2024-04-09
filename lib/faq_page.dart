import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Increase the duration to slow down the animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Slowed down the animation
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.teal.shade300,
        appBar: AppBar(
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0), // Shifts the title down
            child: Text(
              'FAQs',
              style: GoogleFonts.abel(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.w500,
                  letterSpacing: screenSize.width * 0.03,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.teal.shade300,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                // Create a staggered animation for each item
                final animation = Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    // Each item's animation is delayed by 100ms more than the previous one
                    curve: Interval(
                      (index / 5) * 0.5, // Staggered start time
                      0.8, // Extended end time to slow the animation
                      curve: Curves.easeOut,
                    ),
                  ),
                );

                return _buildFaqItem(index, context, animation);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(
      int index, BuildContext context, Animation<Offset> animation) {
    final faqItems = [
      {
        "question": "How do I search for new chats?",
        "answer": "Chats > Search Icon in Top Left"
      },
      {
        "question": "How do I edit pdfs?",
        "answer": "Long-press the pdf in the chat"
      },
      {
        "question": "How do I refresh the page?",
        "answer": "Pull down to refresh the page"
      },
      {
        "question": "How do I know who sent the broadcast pdf?",
        "answer":
            "Tap on the profile picture to see uploader name and time of uploading"
      },
      {
        "question": "Credits",
        "answer":
            "SWD Nucleus - Opportunity and Guidance\nRiddhi Chatterjee - App Testing\nAryan Dalmia - App Development"
      },
    ];

    return SlideTransition(
      position: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faqItems[index]["question"]!,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            faqItems[index]["answer"]!,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
