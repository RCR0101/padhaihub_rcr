// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padhaihub_v2/bloc/notes_bloc/notes_bloc.dart';
import 'package:padhaihub_v2/bloc/notes_bloc/notes_event.dart';
import 'package:padhaihub_v2/bloc/sign_in_bloc/sign_in_bloc.dart';
import 'package:padhaihub_v2/overview.dart';
import 'bloc/chat_bloc/chat_bloc.dart';
import 'bloc/overview_bloc/overview_bloc.dart';
import 'bloc/overview_bloc/overview_event.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(App());
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(DatabaseRepository()),
        ),
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(),
        ),
        BlocProvider<BroadcastBLoC>(
          create: (context) =>
              BroadcastBLoC()..add(CalculateUnreadNotesEvent()),
          child: MyLandingPage(title: 'PadhaiHub'),
        ),
        BlocProvider<OverviewBloc>(
          create: (context) => OverviewBloc()..add(LoadUnreadCount()),
          child: MyLandingPage(title: 'PadhaiHub'),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PadhaiHub',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal.shade400),
          useMaterial3: true,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return currentUser != null
        ? MyLandingPage(title: 'PadhaiHub')
        : MyHomePage(title: 'PadhaiHub');
  }
}
