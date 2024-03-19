import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_sys.dart';

class MyLandingPage extends StatelessWidget {
  final String title;

  const MyLandingPage({super.key, required this.title});

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
              Text(
                'PADHAIHUB',
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
              Expanded(
                child: SingleChildScrollView(
                  // Use SingleChildScrollView to prevent overflow
                  padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: Text("While you were away...",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.signikaNegative(
                                textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.085,
                            ))), // Adjusted size using screen width
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  actionButton(
                    context,
                    Icons.notes_rounded,
                    "Notes",
                    () {
                      // Define what the "Notes" button should do
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage()));
                    },
                  ), // Adjust spacing as needed
                  actionButton(
                    context,
                    Icons.message,
                    "Chats",
                    () {
                      // Define what the "Chats" button should do
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ChatPage()));
                    },
                  ), // Adjust spacing as needed
                  actionButton(
                    context,
                    Icons.person,
                    "Profile",
                    () {
                      // Define what the "Profile" button should do
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    },
                  ),
                ],
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
