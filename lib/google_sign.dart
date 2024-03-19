import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
