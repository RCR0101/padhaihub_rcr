import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'user_data/user_model.dart';
import 'package:google_fonts/google_fonts.dart'; // Assuming you have a User model class

class NewUsersListPage extends StatefulWidget {
  @override
  _NewUsersListPageState createState() => _NewUsersListPageState();
}

class _NewUsersListPageState extends State<NewUsersListPage> {
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
          'SEARCH',
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                  backgroundColor: Colors.transparent,
                ),
                title: Text(user.name),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ChatPage(
                  //         _user:
                  //             user),
                  //   ),
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }
}
