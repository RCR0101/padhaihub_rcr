import 'dart:io';

abstract class ProfileEvent {}

class LoadUserProfile extends ProfileEvent {}

class UpdateProfilePicture extends ProfileEvent {
  final File image;

  UpdateProfilePicture(this.image);
}
