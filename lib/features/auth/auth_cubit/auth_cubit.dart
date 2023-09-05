import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../constant/app_image.dart';
import '../../../helper/cache_helper.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    UserCredential? credential;
    UserModel? userModel;

    try {
      emit(LoginLoading());
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user!.emailVerified) {
        if (credential.user?.metadata.creationTime ==
            credential.user?.metadata.lastSignInTime) {
          userModel = UserModel(
              userId: FirebaseAuth.instance.currentUser?.uid,
              displayName: CacheHelper.prefs?.getString('display_name'),
              email: credential.user?.email,
              image: AppImage.icon);
          await UserService.uploadUserInformation(userModel: userModel);
          await CacheHelper.prefs?.remove('display_name');
        }
        await UserService.getUserInformation();
        emit(LoginSuccessfully());
      } else {
        emit(LoginConfirmation());
      }
    } on FirebaseAuthException catch (e) {
      emit(LoginFirebaseFailed(e.toString()));
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
      if (!userCredential.user!.emailVerified) {
        await CacheHelper.prefs?.setString('display_name', name);
        await userCredential.user!.sendEmailVerification();
        emit(SignUpSuccessfully());
      }
    } on FirebaseAuthException catch (e) {
      emit(SignUpFirebaseFailed(e.toString()));
    } catch (e) {
      emit(SignUpFailed(e.toString()));
    }
  }
}
