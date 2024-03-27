import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'overview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "bloc/sign_in_bloc/sign_in_bloc.dart";
import "bloc/sign_in_bloc/sign_in_event.dart";
import "bloc/sign_in_bloc/sign_in_state.dart";

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Colors.black,
      body: SafeArea(
        // Wrap with SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              // Adjust padding based on screen size
              padding: EdgeInsets.all(screenSize.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image(
                    width: screenSize.width * 0.2, // Responsive width
                    image: const AssetImage('images/app_logo.png'),
                  ),
                  SizedBox(
                      height: screenSize.height * 0.02), // Responsive height
                  Text('PadhaiHub',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifText(
                        textStyle: TextStyle(
                            color: Colors.white,
                            letterSpacing: .5,
                            fontSize:
                                screenSize.width * 0.1), // Responsive font size
                      )),
                  SizedBox(
                      height: screenSize.height * 0.05), // Responsive height
                  Text(
                      'Welcome to PadhaiHub, a platform which gives you the freedom to share notes with anybody in BITS Pilani Hyderabad Campus!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            color: Colors.white,
                            letterSpacing: .5,
                            fontSize: screenSize.width *
                                0.045), // Responsive font size
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04), // Responsive padding
        child: SizedBox(
            height: 60.0, // Consider making this responsive if needed
            child: BlocProvider(
              create: (context) => SignInBloc(),
              child: BlocConsumer<SignInBloc, SignInState>(
                listener: (context, state) {
                  if (state is SignInSuccessState) {
                    Fluttertoast.showToast(
                        gravity: ToastGravity.CENTER,
                        msg: "Login Successful"); // Optional: Notify user
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyLandingPage(
                                  title: 'PadhaiHub',
                                )));
                  } else if (state is SignInFailureState) {
                    Fluttertoast.showToast(msg: "Login Failed: ${state.error}");
                  }
                },
                builder: (context, state) {
                  if (state is SignInLoadingState) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                    width: screenSize.width * 0.34,
                    height: screenSize.height * 0.05,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        BlocProvider.of<SignInBloc>(context)
                            .add(SignInWithGooglePressed());
                      },
                      icon: const Icon(Icons.person, color: Colors.black),
                      label: Text(
                        'Login',
                        style: GoogleFonts.anta(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: MediaQuery.of(context).size.width *
                                  0.05), // Consider making font size responsive if needed
                        ),
                      ),
                    ),
                  );
                },
              ),
            )),
      ),
    );
  }
}
