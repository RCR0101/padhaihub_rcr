import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padhaihub_v2/bloc/profile_bloc/profile_event.dart';
import 'package:padhaihub_v2/home.dart';

import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/profile_bloc/profile_state.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  File? _image;
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadUserProfile());
  }

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        context.read<ProfileBloc>().add(UpdateProfilePicture(_image!));
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  Widget profileImageWidget = Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(screenSize.width * 0.15),
                    ),
                    width: screenSize.width * 0.3,
                    height: screenSize.width * 0.3,
                    child: Icon(Icons.camera_alt, color: Colors.grey[800]),
                  );

                  if (state is ProfileLoaded) {
                    if (_image != null) {
                      profileImageWidget = ClipRRect(
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.15),
                        child: Image.file(
                          _image!,
                          width: screenSize.width * 0.3,
                          height: screenSize.width * 0.3,
                          fit: BoxFit.fill,
                        ),
                      );
                    }
                    // Show imageUrl if _image is null and imageUrl is not empty
                    else if (state.imageUrl.isNotEmpty) {
                      profileImageWidget = ClipRRect(
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.15),
                        child: Image.network(
                          state.imageUrl,
                          width: screenSize.width * 0.3,
                          height: screenSize.width * 0.3,
                          fit: BoxFit.fill,
                        ),
                      );
                    }
                  }

                  return Center(
                    child: GestureDetector(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: screenSize.width * 0.15,
                        backgroundColor: Colors.white,
                        child: profileImageWidget,
                      ),
                    ),
                  );
                },
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
                      SizedBox(height: screenSize.height * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoaded) {
                              return TextFormField(
                                readOnly: true,
                                initialValue: state.firstName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              );
                            } else {
                              return Container(); // Show an empty container or loading spinner
                            }
                          },
                        ),
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
                      SizedBox(height: screenSize.height * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoaded) {
                              return TextFormField(
                                readOnly: true,
                                initialValue: state.lastName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              );
                            } else {
                              return Container(); // Show an empty container or loading spinner
                            }
                          },
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width *
                                0.05), // Adjusted padding using screen width
                        child: Text("Email",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.signikaNegative(
                                textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenSize.width * 0.065,
                            ))),
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05),
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoaded) {
                              return TextFormField(
                                initialValue: state.email,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              );
                            } else {
                              return Container(); // Show an empty container or loading spinner
                            }
                          },
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.06),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.05),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _logout(context);
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red, // Text color
                              shadows: [
                                BoxShadow(
                                  color: Colors.redAccent
                                      .withOpacity(0.7), // Neon glow color
                                  blurRadius: 10.0, // Glow effect
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
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
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'PadhaiHub'),
      ),
    );
  }
}
