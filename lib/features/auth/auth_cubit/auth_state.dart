part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class ObsucreChanged extends AuthState {}

class TypeChanged extends AuthState {}

// login

class LoginLoading extends AuthState {}

class LoginSuccessfully extends AuthState {}

class LoginConfirmation extends AuthState {}

class LoginFailed extends AuthState {
  final String errorMsg;
  LoginFailed(this.errorMsg);
}

// signin with google

class SignINWithGoogleLoading extends AuthState {}

class SignINWithGoogleSuccessfully extends AuthState {}

class SignINWithGoogleFailed extends AuthState {
  final String errorMsg;
  SignINWithGoogleFailed(this.errorMsg);
}

// signUp

class SignUpLoading extends AuthState {}

class SignUpSuccessfully extends AuthState {}

class SignUpFailed extends AuthState {
  final String errorMsg;
  SignUpFailed(this.errorMsg);
}
