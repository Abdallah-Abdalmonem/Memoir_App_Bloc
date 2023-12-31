import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/auth/auth_cubit/auth_cubit.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';
import 'package:memoir_app_bloc/helper/cache_helper.dart';

import '../../../constant/app_image.dart';
import '../../../constant/app_routes.dart';
import '../../../helper/custom_snackbar.dart';
import '../../../helper/toast_helper.dart';
import '../../widgets/auth_continer.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});
  @override
  GlobalKey<FormState> signInKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;

    final cubit = BlocProvider.of<AuthCubit>(context);
    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccessfully) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            CacheHelper.setSignin().then((value) =>
                BlocProvider.of<HomeCubit>(context)
                  ..signinWithEmailAndPassword = true);
            clearTextFormField();
            ToastHelper.toastSuccess(msg: 'signin success!!');
          }
          if (state is LoginLoading) {
            CustomSnackBar(context, 'Please Wait...');
          }
          if (state is LoginFailed) {
            CustomSnackBarfailure(context, state.errorMsg);
          }
          if (state is LoginConfirmation) {
            CustomSnackBar(
                context, 'Please check your email to confirm your account');
          }
          if (state is SignINWithGoogleSuccessfully) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            CacheHelper.setSignin().then(
                (value) => BlocProvider.of<HomeCubit>(context).getNotes());
            clearTextFormField();
            ToastHelper.toastSuccess(msg: 'signin success!!');
          }
          if (state is SignINWithGoogleFailed) {
            CustomSnackBarfailure(context, state.errorMsg);
          }
          if (state is SignINWithGoogleLoading) {
            CustomSnackBar(context, 'Please Wait...');
          }
        },
        child: Scaffold(
          // backgroundColor: Colors.grey[200],
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            toolbarHeight: 40,
            centerTitle: true,
            title: const Text('Memoir', style: TextStyle(color: Colors.black)),
          ),
          body: Form(
            key: signInKey,
            child: Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Image.asset(
                    AppImage.backgroundAuth,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AuthContiner(
                      emailTextEditingController: emailController,
                      passwordTextEditingController: passwordController,
                      navigateText: 'Sign up',
                      tapNavigation: () {
                        clearTextFormField();
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.signup);
                      },
                      onPress: () async {
                        if (signInKey.currentState!.validate()) {
                          await cubit.signIn(
                              email: emailController.text,
                              password: passwordController.text);
                        }
                      },
                      title: 'Sign in',
                      heightScreen: heightScreen,
                      widthtScreen: widthScreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  clearTextFormField() {
    emailController.clear();
    passwordController.clear();
  }
}
