part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class ObsucreChanged extends AuthState {}

class TypeChanged extends AuthState {}

// login

class LoginLoading extends AuthState {}

class LoginSuccessfully extends AuthState {
  LoginSuccessfully();
}

class LoginConfirmation extends AuthState {}

class LoginFirebaseFailed extends AuthState {
  final String errorMsg;
  LoginFirebaseFailed(this.errorMsg);
}

class LoginFailed extends AuthState {
  final String errorMsg;
  LoginFailed(this.errorMsg);
}

// signUp

class SignUpLoading extends AuthState {}

class SignUpSuccessfully extends AuthState {
  SignUpSuccessfully();
}

class SignUpFailed extends AuthState {
  final String errorMsg;
  SignUpFailed(this.errorMsg);
}

class SignUpFirebaseFailed extends AuthState {
  final String errorMsg;
  SignUpFirebaseFailed(this.errorMsg);
}
