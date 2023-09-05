part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

// add notes
class AddNoteLoading extends HomeState {}

class AddNoteSuccessfully extends HomeState {
  AddNoteSuccessfully();
}

class AddNoteFailed extends HomeState {
  final String errorMsg;
  AddNoteFailed(this.errorMsg);
}

// delete note
class DeleteNoteLoading extends HomeState {}

class DeleteNoteSuccessfully extends HomeState {
  DeleteNoteSuccessfully();
}

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

class GetNoteFailed extends HomeState {
  final String errorMsg;
  GetNoteFailed(this.errorMsg);
}

// edit note

class EditNoteLoading extends HomeState {}

class EditNoteSuccessfully extends HomeState {
  EditNoteSuccessfully();
}

class EditNoteFailed extends HomeState {
  final String errorMsg;
  EditNoteFailed(this.errorMsg);
}

// remove profile image
class RemoveProfileImageLoading extends HomeState {}

class RemoveProfileImageSuccessfully extends HomeState {
  RemoveProfileImageSuccessfully();
}

class RemoveProfileImageFailed extends HomeState {
  final String errorMsg;
  RemoveProfileImageFailed(this.errorMsg);
}

// get profile image
class GetProfileImageLoading extends HomeState {}

class GetProfileImageSuccessfully extends HomeState {
  GetProfileImageSuccessfully();
}

class GetProfileImageFailed extends HomeState {
  final String errorMsg;
  GetProfileImageFailed(this.errorMsg);
}

// upload profile image
class UploadProfileImageLoading extends HomeState {}

class UploadProfileImageSuccessfully extends HomeState {
  UploadProfileImageSuccessfully();
}

class UploadProfileImageFailed extends HomeState {
  final String errorMsg;
  UploadProfileImageFailed(this.errorMsg);
}

// refresh note
class RefreshNoteLoading extends HomeState {}

class RefreshNoteSuccessfully extends HomeState {}

class RefreshNoteFailed extends HomeState {
  final String errorMsg;
  RefreshNoteFailed(this.errorMsg);
}
