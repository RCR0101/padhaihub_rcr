// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padhaihub_v2/bloc/notes_bloc/notes_bloc.dart';
import 'package:padhaihub_v2/chat_list.dart';
import 'package:padhaihub_v2/notes.dart';
import 'package:padhaihub_v2/profile_page.dart';
import 'bloc/notes_bloc/notes_event.dart';
import 'bloc/notes_bloc/notes_state.dart';
import 'bloc/overview_bloc/overview_bloc.dart';
import 'bloc/overview_bloc/overview_event.dart';
import 'bloc/overview_bloc/overview_state.dart';
import 'bloc/profile_bloc/profile_bloc.dart';
import 'bloc/profile_bloc/profile_event.dart';

class MyLandingPage extends StatelessWidget {
  final String title;

  const MyLandingPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
                    MyNotesPage(), // Pass the page widget directly
                  ),
                  actionButton(
                    context,
                    Icons.message,
                    "Chats",
                    UsersListPage(), // Pass the page widget directly
                  ),
                  actionButton(
                    context,
                    Icons.person,
                    "Profile",
                    BlocProvider<ProfileBloc>(
                      create: (context) =>
                          ProfileBloc()..add(LoadUserProfile()),
                      child: MyProfilePage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget actionButton(
      BuildContext context, IconData icon, String text, Widget page) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(createRoute(page));
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.black, // Text Color
          backgroundColor: Colors.teal.shade300, // Button background color
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space
          children: <Widget>[
            Icon(icon),
            Text(text,
                style: TextStyle(
                    fontSize: 13)), // Smaller text size for better fitting
          ],
        ),
      ),
    );
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Starts from the right
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class OverviewSection extends StatefulWidget {
  const OverviewSection({super.key});

  @override
  State<OverviewSection> createState() => _OverviewSectionState();
}

class _OverviewSectionState extends State<OverviewSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0), // Start below the screen
      end: Offset.zero, // End at its natural position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    // Start the animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 1000));
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sidePadding = MediaQuery.of(context).size.width * 0.05;
    final double upPadding = MediaQuery.of(context).size.height * 0.05;
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => _refreshContent(context),
        child: LayoutBuilder(
          // Use LayoutBuilder to ensure SingleChildScrollView takes the full height
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      _buildTitle(sidePadding),
                      SizedBox(height: upPadding * 0.5),
                      _buildOverviewMessages(sidePadding, upPadding),
                      _buildOverviewNotes(sidePadding, upPadding),
                    ],
                  ),
                ),
              ),
            );
          },
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

  Widget _buildOverviewMessages(double sidePadding, double upPadding) {
    return BlocBuilder<OverviewBloc, OverviewState>(
      builder: (context, state) {
        if (state is OverviewLoading) {
          return _buildOverviewContent(0, sidePadding, upPadding);
        } else if (state is OverviewLoaded) {
          return _buildOverviewContent(
              state.unreadCount, sidePadding, upPadding);
        } else if (state is OverviewError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePadding),
            child: Text("Error: ${state.message}"),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOverviewNotes(double sidePadding, double upPadding) {
    return BlocBuilder<BroadcastBLoC, BroadcastState>(
      builder: (context, state) {
        if (state is NewNotesCountUpdated) {
          return _buildNotesContent(
              state.newNotesCount, sidePadding, upPadding);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildNotesContent(
      int newNotesCount, double sidePadding, double upPadding) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: sidePadding, vertical: upPadding),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.note_add_outlined,
                      size: 32, color: Colors.green),
                  title: Text(
                    "New Notes",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            MediaQuery.of(context).size.width > 360 ? 18 : 16),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: sidePadding,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      "$newNotesCount",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent(
      int unreadCount, double sidePadding, double upPadding) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
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
                      fontSize:
                          MediaQuery.of(context).size.width > 360 ? 18 : 16,
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
        ),
      ),
    );
  }

  Future<void> _refreshContent(BuildContext context) async {
    context.read<OverviewBloc>().add(LoadUnreadCount());
    context.read<BroadcastBLoC>().add(CalculateUnreadNotesEvent());
  }
}
