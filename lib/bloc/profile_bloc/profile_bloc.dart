import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userData.exists) {
          List<String> nameParts = (userData['name'] ?? 'None None').split(' ');
          String firstName =
              nameParts.isNotEmpty ? nameParts.first : 'First Name';
          String lastName = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : 'Last Name';
          String email = userData['email'];
          emit(ProfileLoaded(
            firstName,
            lastName,
            email,
            imageUrl: userData['imageUrl'] ?? '',
          ));
        } else {
          emit(ProfileError('User data not found.'));
        }
      }
    } catch (e) {
      emit(ProfileError('Failed to fetch user data.'));
    }
  }

  Future<void> _onUpdateProfilePicture(
      UpdateProfilePicture event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String fileName = path.basename(event.image.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/${currentUser.uid}/$fileName');

      try {
        await ref.putFile(event.image);
        final fileURL = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'imageUrl': fileURL});

        // Re-fetch the user profile to update the UI
        add(LoadUserProfile());
      } catch (e) {
        emit(ProfileError('Failed to upload image.'));
      }
    } else {
      emit(ProfileError('No user signed in.'));
    }
  }
}
