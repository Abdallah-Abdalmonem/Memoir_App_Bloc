import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/auth/auth_cubit/auth_cubit.dart';

import '../../../constant/app_image.dart';
import '../../../constant/app_routes.dart';
import '../../../helper/custom_snackbar.dart';
import '../../../helper/toast_helper.dart';
import '../../widgets/auth_continer.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height;

    final cubit = BlocProvider.of<AuthCubit>(context);

    return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccessfully) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.signin);
            ToastHelper.toastSuccess(msg: 'Please confirm your email');
          } else if (state is SignUpLoading) {
            CustomSnackBar(context, 'Please Wait...');
          } else if (state is SignUpFirebaseFailed) {
            CustomSnackBarfailure(context, state.errorMsg);
          } else if (state is SignUpFailed) {
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
            key: signUpKey,
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
                      nameTextEditingController: nameController,
                      heightScreen: heightScreen,
                      widthtScreen: widthScreen,
                      title: 'Sign up',
                      navigateText: 'login',
                      tapNavigation: () {
                        // controller.clearTextFormField();

                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.signin);
                      },
                      onPress: () async {
                        if (signUpKey.currentState!.validate()) {
                          await cubit.signUp(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text);
                          // controller.clearTextFormField();
                          // controller.nameController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
