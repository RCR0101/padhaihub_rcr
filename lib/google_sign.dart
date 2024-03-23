import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      // Check if the email domain is correct
      if (googleUser.email.endsWith('hyderabad.bits-pilani.ac.in')) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Check if this is a new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          try {
            print("About to write to Firestore");
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'id': googleUser.id,
              'name': googleUser.displayName,
              'email': googleUser.email,
              'imageUrl': googleUser.photoUrl
            });
            print("Successfully written to Firestore");
          } catch (e) {
            print("Error adding user to Firestore: $e");
            return null;
          }
        }

        return userCredential.user;
      } else {
        print('Unauthorized domain.');
        return null; // Early return if email domain does not match
      }
    }
  } catch (e) {
    if (e is FirebaseAuthException) {
      print("Firebase Auth Error: ${e.message}");
    } else {
      print(e.toString());
    }
    return null;
  }
  return null;
}
