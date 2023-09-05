import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memoir_app_bloc/features/auth/auth_cubit/auth_cubit.dart';

import '../../constant/app_color.dart';
import '../../constant/app_image.dart';
import '../../constant/app_routes.dart';
import '../../helper/toast_helper.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class AuthContiner extends StatelessWidget {
  const AuthContiner({
    super.key,
    required this.heightScreen,
    required this.widthtScreen,
    required this.title,
    required this.onPress,
    required this.navigateText,
    required this.tapNavigation,
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    this.nameTextEditingController,
  });
  final TextEditingController emailTextEditingController;
  final TextEditingController passwordTextEditingController;
  final TextEditingController? nameTextEditingController;

  final double heightScreen;
  final double widthtScreen;
  final String title;
  final String navigateText;

  final void Function()? tapNavigation;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        // height: heightScreen / 2.3,
        // height: heightScreen * .5,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(25.0)),
            border: Border.all(
              width: 2,
              color: AppColor.buttonColor,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  // minHeight: constraint.maxHeight,
                  // maxHeight: constraint.maxHeight
                  ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      '$title',
                      style: const TextStyle(
                          color: AppColor.buttonColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 20),
                    title != 'Sign in'
                        ? Column(
                            children: [
                              CustomTextFormField(
                                textController: nameTextEditingController,
                                validator: (p0) {
                                  if (p0!.isEmpty && p0 == '') {
                                    return 'name required';
                                  }
                                },
                                hintText: 'name',
                                labelText: 'name',
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : const SizedBox(),
                    CustomTextFormField(
                      textController: emailTextEditingController,
                      autoValidate: AutovalidateMode.onUserInteraction,
                      validator: (p0) {
                        if (!p0!.contains('@')) {
                          return 'email not vailed should be contain @';
                        }
                      },
                      hintText: 'Email',
                      labelText: 'Email',
                    ),

                    const SizedBox(height: 20),

                    CustomTextFormField(
                      textController: passwordTextEditingController,
                      autoValidate: AutovalidateMode.onUserInteraction,
                      validator: (p0) {
                        if (p0!.isEmpty) {
                          return 'Password can\'t be empty';
                        } else if (p0.length < 6) {
                          return 'Password not vailed should be longer than 6';
                        }
                      },
                      hintText: 'Password',
                      labelText: 'Password',
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      textButton: '$title',
                      colorButton: AppColor.buttonColor,
                      colorText: Colors.white,
                      onPressed: onPress,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'have you an account?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: tapNavigation,
                          child: Text(
                            '  $navigateText',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // if screen is sign in show button continue
                    title == 'Sign in'
                        ? singinWithGoogleButtonBuilder(context)
                        : const Spacer(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Column singinWithGoogleButtonBuilder(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: widthtScreen / 3,
              height: 20,
              child: const Divider(
                // height: 10,
                color: Colors.grey,
              ),
            ),
            const Text('OR'),
            SizedBox(
              height: 20,
              width: widthtScreen / 3,
              child: const Divider(
                // height: 30,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await BlocProvider.of<AuthCubit>(context).signInWithGoogle();
              },
              child: Container(
                padding: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColor.borderColor.withOpacity(.1)),
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {},
                      icon: Image.asset(AppImage.googleIcon),
                      iconSize: 30,
                    ),
                    const Text('Continue with google'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
