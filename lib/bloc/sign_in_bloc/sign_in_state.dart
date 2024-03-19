import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SignInState extends Equatable {
  @override
  List<Object> get props => [];
}

class SignInInitialState extends SignInState {}

class SignInLoadingState extends SignInState {}

class SignInSuccessState extends SignInState {
  final User user;

  SignInSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class SignInFailureState extends SignInState {
  final String error;

  SignInFailureState(this.error);

  @override
  List<Object> get props => [error];
}
