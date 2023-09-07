import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';

import 'bloc_observer.dart';
import 'constant/app_color.dart';
import 'constant/app_routes.dart';
import 'features/auth/auth_cubit/auth_cubit.dart';
import 'firebase_options.dart';
import 'helper/cache_helper.dart';

void main() async {
  Bloc.observer = MyBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CacheHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(),
        ),
        BlocProvider<HomeCubit>(
          create: (BuildContext context) => HomeCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Memoir',
        theme: ThemeData(
          primarySwatch: AppColor.primaryColor,
        ),
        initialRoute:
            CacheHelper.isSignin() == true ? AppRoutes.home : AppRoutes.signin,
        routes: routes,
      ),
    );
  }
}
