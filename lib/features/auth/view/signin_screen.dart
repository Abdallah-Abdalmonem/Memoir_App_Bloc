import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/constant/app_routes.dart';
import 'package:memoir_app_bloc/helper/custom_snackbar.dart';
import 'package:memoir_app_bloc/helper/toast_helper.dart';

import '../../../constant/app_image.dart';
import '../../widgets/auth_continer.dart';
import '../auth/auth_cubit.dart';

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
            ToastHelper.toastSuccess(msg: 'signin success!!');
          } else if (state is LoginFirebaseFailed) {
            CustomSnackBarfailure(context, state.errorMsg);
          } else if (state is LoginConfirmation) {
            CustomSnackBar(
                context, 'Please check your email to confirm your account');
          } else if (state is LoginLoading) {
            CustomSnackBar(context, 'Please Wait...');
          } else if (state is LoginFailed) {
            CustomSnackBarfailure(context, state.errorMsg);
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
                        // controller.clearTextFormField();

                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.signup);
                      },
                      onPress: () async {
                        if (signInKey.currentState!.validate()) {
                          await cubit.signIn(
                              email: emailController.text,
                              password: passwordController.text);
                          // controller.clearTextFormField();
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
}
