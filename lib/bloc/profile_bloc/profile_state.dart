abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String email;

  ProfileLoaded(this.firstName, this.lastName, this.email,
      {this.imageUrl = ''});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
