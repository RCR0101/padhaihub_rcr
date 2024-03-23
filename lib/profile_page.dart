import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  File? _image;
  final picker = ImagePicker();
  String _firstName = '';
  String _lastName = '';
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _firstName = userData['f_name'] ?? 'First Name';
          _lastName = userData['l_name'] ?? 'Last Name';
        });
      }
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadPic(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && _image != null) {
      String fileName = Path.basename(_image!.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/${currentUser.uid}/$fileName');
      firebase_storage.UploadTask uploadTask = ref.putFile(_image!);

      try {
        await uploadTask.whenComplete(() {});
        final fileURL = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users') // Assuming 'users' is your collection
            .doc(currentUser.uid) // Document ID equals to user's UID
            .update(
                {'imageUrl': fileURL}); // Field to update with new image URL

        setState(() {
          print("Profile Picture uploaded and URL updated in Firestore");
        });
      } catch (e) {
        print("Error during image upload or Firestore update: $e");
      }
    } else {
      print('No image selected or user not logged in.');
    }
  }

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
                    'PROFILE',
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
              SizedBox(height: screenSize.height * 0.04),
              Center(
                child: GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: CircleAvatar(
                    radius: screenSize.width * 0.15,
                    backgroundColor: Colors.white,
                    child: _image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenSize.width * 0.15),
                            child: Image.file(
                              _image!,
                              width: screenSize.width * 0.3,
                              height: screenSize.width * 0.3,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.15)),
                            width: screenSize.width * 0.3,
                            height: screenSize.width * 0.3,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  // Use SingleChildScrollView to prevent overflow
                  padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: Text("First Name",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.signikaNegative(
                                textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.065,
                            ))),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: TextFormField(
                            initialValue: _firstName,
                            readOnly: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'First Name')),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: Text("Last Name",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.signikaNegative(
                                textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.065,
                            ))),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: TextFormField(
                            initialValue: _lastName,
                            readOnly: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Last Name')),
                      ),
                    ],
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
