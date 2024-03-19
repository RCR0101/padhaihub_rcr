// ignore_for_file: unused_import

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './sign_in_event.dart';
import './sign_in_state.dart';
import '../../google_sign.dart'; // Import your signInWithGoogle method here

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitialState()) {
    on<SignInWithGooglePressed>(_onSignInWithGooglePressed);
  }

  Future<void> _onSignInWithGooglePressed(
      SignInWithGooglePressed event, Emitter<SignInState> emit) async {
    emit(SignInLoadingState());
    try {
      User? user = await signInWithGoogle();
      if (user != null) {
        emit(SignInSuccessState(user));
      } else {
        emit(SignInFailureState('Sign-In Failed'));
      }
    } catch (e) {
      emit(SignInFailureState(e.toString()));
    }
  }
}
