import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padhaihub_v2/new_chats.dart';
import 'bloc/chat_bloc/chat_bloc.dart';
import 'chat_page.dart';
import 'user_data/user_model.dart';
import 'package:google_fonts/google_fonts.dart'; // Assuming you have a User model class

class UsersListPage extends StatefulWidget {
  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  Future<List<User_D>> getUsersFromFirestore() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs
        .map((doc) => User_D(
            id: doc.id,
            name: doc['name'],
            email: doc['email'],
            imageUrl: doc['imageUrl']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.teal.shade300,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CHATS',
          textAlign: TextAlign.center,
          style: GoogleFonts.abel(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width *
                      0.08, // Adjusted size using screen width
                  fontWeight: FontWeight.w500,
                  letterSpacing:
                      screenSize.width * 0.03)), // Adjusted letter spacing
        ),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewUsersListPage()));
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            alignment: Alignment.centerRight,
          )
        ],
      ),
      body: FutureBuilder<List<User_D>>(
        future: getUsersFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              String chatId = determineChatId(
                  FirebaseAuth.instance.currentUser!.uid, user.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(toCapitalCase(user.name)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider<ChatBloc>(
                        create: (context) => ChatBloc(DatabaseRepository()),
                        child: ChatPage(userId: user.id, chatId: chatId),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

String toCapitalCase(String input) {
  return input.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String determineChatId(String currentUserId, String otherUserId) {
  // Ensure the order is always the same by sorting
  List<String> ids = [currentUserId, otherUserId];
  ids.sort();

  // Concatenate the sorted user IDs to form the chat ID
  String chatId = ids.join('_');
  return chatId;
}
