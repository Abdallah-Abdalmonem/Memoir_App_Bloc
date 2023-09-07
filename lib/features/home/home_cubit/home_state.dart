part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

// add notes
class AddNoteLoading extends HomeState {}

class AddNoteSuccessfully extends HomeState {}

class AddNoteFailed extends HomeState {
  final String errorMsg;
  AddNoteFailed(this.errorMsg);
}

// delete note
class DeleteNoteLoading extends HomeState {}

class DeleteNoteSuccessfully extends HomeState {}

class DeleteNoteFailed extends HomeState {
  final String errorMsg;
  DeleteNoteFailed(this.errorMsg);
}

// get notes
class GetNoteLoading extends HomeState {}

class GetNoteSuccessfully extends HomeState {
  final List<NoteModel> notesList;
  GetNoteSuccessfully(this.notesList);
}

class GetZeroNoteSuccessfully extends HomeState {}

class GetNoteFailed extends HomeState {
  final String errorMsg;
  GetNoteFailed(this.errorMsg);
}

// edit note

class EditNoteLoading extends HomeState {}

class EditNoteSuccessfully extends HomeState {}

class EditNoteFailed extends HomeState {
  final String errorMsg;
  EditNoteFailed(this.errorMsg);
}

// remove profile image
class RemoveProfileImageLoading extends HomeState {}

class RemoveProfileImageSuccessfully extends HomeState {}

class RemoveProfileImageFailed extends HomeState {
  final String errorMsg;
  RemoveProfileImageFailed(this.errorMsg);
}

// get profile image
class GetProfileImageLoading extends HomeState {}

class GetProfileImageSuccessfully extends HomeState {}

class GetProfileImageFailed extends HomeState {
  final String errorMsg;
  GetProfileImageFailed(this.errorMsg);
}

// update profile image
class UpdateProfileImageLoading extends HomeState {}

class UpdateProfileImageSuccessfully extends HomeState {}

class UpdateProfileImageFailed extends HomeState {
  final String errorMsg;
  UpdateProfileImageFailed(this.errorMsg);
}

// get information user

class GetUserInformationLoading extends HomeState {}

class GetUserInformationSuccessfully extends HomeState {}

class GetUserInformationFailed extends HomeState {
  final String errorMsg;
  GetUserInformationFailed(this.errorMsg);
}
