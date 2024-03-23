import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padhaihub_v2/chat_list.dart';

class MyNotesPage extends StatelessWidget {
  const MyNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final Size screenSize = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor:
            Colors.teal.shade300, // Background color for the entire page
        body: SafeArea(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space out the boxes
            children: <Widget>[
              SizedBox(
                  height: screenSize.height *
                      0.01), // Adjusted size using screen height
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  Text(
                    'NOTES',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abel(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width *
                                0.08, // Adjusted size using screen width
                            fontWeight: FontWeight.w500,
                            letterSpacing: screenSize.width *
                                0.03)), // Adjusted letter spacing
                  ),
                  SizedBox(
                    width: screenSize.width * 0.1,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  // Use SingleChildScrollView to prevent overflow
                  padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: SizedBox(
                    height: 5,
                  ),
                ),
              ),
              SizedBox(
                  height: screenSize.height *
                      0.01), // Adjusted size using screen height
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton(BuildContext context, IconData icon, String text,
      VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.black,
        minimumSize: const Size(60, 60),
      ),
      onPressed:
          onPressed, // Use the onPressed parameter for the button's functionality
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
