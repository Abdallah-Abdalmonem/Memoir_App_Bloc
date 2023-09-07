import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memoir_app_bloc/helper/toast_helper.dart';

import '../../../constant/app_image.dart';
import '../../../helper/cache_helper.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  UserModel? userModel;

  Future<void> signIn({required String email, required String password}) async {
    UserCredential? credential;
    try {
      emit(LoginLoading());
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user!.emailVerified) {
        // if (credential.user?.photoURL == null) {
        //   // UserModel userModel = UserModel(
        //   //     userId: FirebaseAuth.instance.currentUser?.uid,
        //   //     displayName: CacheHelper.prefs?.getString('display_name'),
        //   //     email: credential.user?.email,
        //   //     image: AppImage.icon);
        //   // await UserService.uploadUserInformation(userModel: userModel);
        //   // await CacheHelper.prefs?.remove('display_name');
        // }
        emit(LoginSuccessfully());
      } else {
        ToastHelper.toastfailure(msg: 'EmailNotVerified');
      }
    } on FirebaseAuthException catch (e) {
      emit(LoginFailed(e.toString()));
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      emit(SignUpLoading());
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      userModel = UserModel(
          userId: FirebaseAuth.instance.currentUser?.uid,
          displayName: name,
          email: userCredential.user?.email);
      await UserService.createUserInformation(userModel: userModel!);

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        emit(SignUpSuccessfully());
      }
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailed(e.toString()));
    } catch (e) {
      emit(SignUpFailed(e.toString()));
    }
  }

  Future signinWithGoogle() async {
    try {
      emit(SignINWithGoogleLoading());
      UserCredential? userCredential = await signInWithGoogle();
      if (userCredential != null) {
        if (userCredential.user!.emailVerified) {
          emit(SignINWithGoogleSuccessfully());
        } else {
          ToastHelper.toastfailure(msg: 'EmailNotVerified');
        }
      }
    } catch (e) {
      emit(SignINWithGoogleFailed(e.toString()));
    }
  }

  Future<UserCredential?>? signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final OAuthCredential credential = await GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      ToastHelper.toastfailure(msg: '$e');
      return null;
    }
  }
}
