import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padhaihub_v2/bloc/notes_bloc/notes_bloc.dart';
import 'package:padhaihub_v2/chat_list.dart';
import 'package:padhaihub_v2/notes.dart';
import 'package:padhaihub_v2/profile_page.dart';

import 'bloc/overview_bloc/overview_bloc.dart';
import 'bloc/overview_bloc/overview_state.dart';
import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/profile_bloc/profile_event.dart';

class MyLandingPage extends StatelessWidget {
  final String title;

  const MyLandingPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final Size screenSize = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor:
                Colors.teal.shade300, // Background color for the entire page
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0), // Adjust the padding as needed
                    child: Text(
                      'PADHAIHUB',
                      textAlign: TextAlign.center,
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
                  OverviewSection(),
                ],
              ),
            ),

            bottomNavigationBar: BottomAppBar(
              height: screenSize.height * 0.115,
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  actionButton(
                    context,
                    Icons.notes_rounded,
                    "Broadcast",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => BroadcastBLoC(),
                              child: MyNotesPage(),
                            ),
                          ));
                    },
                  ),
                  actionButton(
                    context,
                    Icons.message,
                    "Chats",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UsersListPage()));
                    },
                  ),
                  actionButton(
                    context,
                    Icons.person,
                    "Profile",
                    () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider<ProfileBloc>(
                              create: (context) =>
                                  ProfileBloc()..add(LoadUserProfile()),
                              child: MyProfilePage(),
                            ),
                          ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget actionButton(BuildContext context, IconData icon, String text,
      VoidCallback onPressed) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.black, // Text Color
          backgroundColor: Colors.teal.shade300, // Button background color
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space
          children: <Widget>[
            Icon(
              icon,
            ),
            Text(text,
                style: TextStyle(
                    fontSize: 13)), // Smaller text size for better fitting
          ],
        ),
      ),
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double sidePadding = MediaQuery.of(context).size.width * 0.05;
    final double upPadding = MediaQuery.of(context).size.height * 0.05;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20), // Use fixed size for consistency
            _buildTitle(sidePadding),
            _buildOverviewBlocBuilder(sidePadding, upPadding),
          ],
        ),
      ),
    );
  }

  Padding _buildTitle(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Text(
        "While you were away...",
        textAlign: TextAlign.left,
        style: GoogleFonts.signikaNegative(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: padding * 1.75, // Consider using a responsive size
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewBlocBuilder(double sidePadding, double upPadding) {
    return BlocBuilder<OverviewBloc, OverviewState>(
      builder: (context, state) {
        if (state is OverviewLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OverviewLoaded) {
          return _buildOverviewContent(
              state.unreadCount, sidePadding, upPadding);
        } else if (state is OverviewError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: Text("Error: ${state.message}"),
          );
        } else {
          return SizedBox
              .shrink(); // For OverviewInitial or any other unhandled state
        }
      },
    );
  }

  Card _buildOverviewContent(
      int unreadCount, double sidePadding, double upPadding) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sidePadding,
          vertical: upPadding,
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.mail_outline,
                size: 32,
                color: Colors.blue,
              ),
              title: Text(
                "Unread Messages",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: sidePadding,
              bottom: 0,
              child: Center(
                child: Text(
                  "$unreadCount",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
