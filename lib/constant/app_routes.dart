import 'package:flutter/material.dart';
import 'package:memoir_app_bloc/features/home/home_screen.dart';
import 'package:memoir_app_bloc/features/note/note_screen.dart';

import '../features/auth/view/signin_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/widgets/image_screen.dart';

class AppRoutes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String imageScreen = '/image_screen';
  static const String noteScreen = '/note_screen';
}

Map<String, Widget Function(BuildContext)> routes = {
  AppRoutes.signin: (context) => SigninScreen(),
  AppRoutes.signup: (context) => SignupScreen(),
  AppRoutes.home: (context) => HomeScreen(),
  AppRoutes.imageScreen: (context) => ImageScreen(),
  AppRoutes.noteScreen: (context) => NoteScreen(),

  // AppRoutes.confirmation: (context) => ConfirmScreen(),
  // AppRoutes.profile: (context) => ProfileScreen(),
  // AppRoutes.bottomNavigationBar: (context) => BottomNavigationBarScreen(),
  // AppRoutes.updateProfile: (context) => UpdateProfileScreen(),
};
