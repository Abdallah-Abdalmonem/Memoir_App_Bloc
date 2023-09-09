import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoir_app_bloc/helper/cache_helper.dart';
import 'package:memoir_app_bloc/models/user_model.dart';

import '../../../helper/toast_helper.dart';
import '../../../models/note_model.dart';
import '../../../services/image_service.dart';
import '../../../services/note_service.dart';
import '../../../services/user_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  static HomeCubit get(context) => BlocProvider.of(context);

  List<Color> colorList = [
    Colors.black,
    Colors.pink.withOpacity(.5),
    Colors.green.withOpacity(.2),
    Colors.purpleAccent.withOpacity(.2),
    Colors.purple.withOpacity(.5),
    Colors.yellow.withOpacity(.5),
    Colors.black.withOpacity(.5),
    Colors.green.withOpacity(.5),
    Colors.grey.withOpacity(.5),
    Colors.orange.withOpacity(.5),
    Colors.brown.withOpacity(.5),
    Colors.blue.withOpacity(.5),
  ];
  Color selectedColor = Colors.black;
  Color editColor = Colors.black;

  List<NoteModel> notesList = [];

  User? currentUser = FirebaseAuth.instance.currentUser;

  bool signinWithEmailAndPassword = false;

  UserModel? userModel;

  bool isFavorite = false;

  List<NoteModel> favoriteNoteList = [];

  loadUser() async {
    await getImageProfile();
    await getUserInformation();
    await getNotes();
  }

  changeFavorite({required String noteId, required bool isFavoriteOld}) async {
    emit(ChangeFavoriteLoading());
    isFavorite = !isFavoriteOld;
    await NoteService.editFavoriteNote(isFavorite: isFavorite, noteId: noteId);
    emit(ChangeFavoriteSuccessfully());
    await getNotes();
  }

  Future<UserModel?> getUserInformation() async {
    try {
      emit(GetUserInformationLoading());
      userModel = await UserService.getUserInformation();
      if (userModel?.displayName != null) {
        signinWithEmailAndPassword = true;
      }
      emit(GetUserInformationSuccessfully());
    } catch (e) {
      emit(GetUserInformationSuccessfully());
    }
    return userModel;
  }

  Future<String?> getImageProfile() async {
    try {
      emit(GetProfileImageLoading());
      Reference refStorage = FirebaseStorage.instance
          .ref('image/${currentUser?.uid}/profile_image');

      userModel?.image = await refStorage.getDownloadURL();
      if (userModel?.image != null) {
        return userModel?.image;
      }
      emit(GetProfileImageSuccessfully());
    } catch (e) {
      emit(GetProfileImageFailed(e.toString()));
    }
    return null;
  }

  Future<List<NoteModel>?> getNotes() async {
    try {
      emit(GetNoteLoading());
      notesList.clear();
      favoriteNoteList.clear();
      List<NoteModel> response = await NoteService.getNotes();
      notesList = response;

      response
          .where((element1) => element1.isFavorite == true)
          .forEach((element2) {
        favoriteNoteList.add(element2);
      });

      if (response.isNotEmpty) {
        print('get note');
        print(response.length);
        emit(GetNoteSuccessfully(response));
        return response;
      } else {
        print('get note');
        print(response.length);
        emit(GetZeroNoteSuccessfully());
      }
    } catch (e) {
      emit(GetNoteFailed(e.toString()));
    }
    return null;
  }

  Future<void> addNote({
    required String title,
    required String note,
  }) async {
    try {
      emit(AddNoteLoading());
      NoteModel noteModel = NoteModel(
        title: title,
        note: note,
        color: selectedColor.toString(),
        createdOn: Timestamp.now(),
        isFavorite: false,
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
      await NoteService.addNote(noteModel: noteModel).then((value) {
        emit(AddNoteSuccessfully());
      });
      await getNotes();
    } catch (e) {
      emit(AddNoteFailed(e.toString()));
      ToastHelper.toastfailure(msg: e.toString());
      print(e);
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await NoteService.deleteNote(noteId);
      await getNotes();
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
    }
  }

  Future<void> deleteAllNote() async {
    try {
      if (notesList.isNotEmpty) {
        await NoteService.deleteAllNote();
        notesList.clear();
        await getNotes();
      } else {
        ToastHelper.toastfailure(msg: 'There is no notes');
      }
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
    }
  }

  Future<void> editNote(
      {required NoteModel oldNoteModel,
      required String editTitle,
      required String editNote}) async {
    try {
      emit(EditNoteLoading());
      NoteModel noteModel;
      noteModel = NoteModel(
        userId: FirebaseAuth.instance.currentUser?.uid,
        noteId: oldNoteModel.noteId,
        title: editTitle.isEmpty ? oldNoteModel.title : editTitle,
        note: editNote.isEmpty ? oldNoteModel.note : editNote,
        color: editColor.toString(),
        createdOn: oldNoteModel.createdOn,
        isFavorite: oldNoteModel.isFavorite,
        editOn: Timestamp.now(),
      );
      await NoteService.editNote(
          noteId: oldNoteModel.noteId.toString(), noteModel: noteModel);
      emit(EditNoteSuccessfully());
      await getNotes();
    } catch (e) {
      emit(EditNoteFailed(e.toString()));
      ToastHelper.toastfailure(msg: e.toString());
    }
  }

  Future removeProfileImage() async {
    try {
      if (userModel?.image != null) {
        emit(RemoveProfileImageLoading());
        await FirebaseStorage.instance
            .ref('image/${currentUser?.uid}/profile_image')
            .delete();
        userModel?.image = null;
        await UserService.updateUserInformation(userModel: userModel!);
        emit(RemoveProfileImageSuccessfully());
      }
    } catch (e) {
      emit(RemoveProfileImageFailed(e.toString()));
    }
  }

  updateProfileImage({required String fromWhat}) async {
    XFile? image;

    switch (fromWhat) {
      case 'camera':
        image = await ImageServices.pickImageFromCamera();
        break;
      case 'gallery':
        image = await ImageServices.pickImageFromGallery();
        break;
      default:
        print('there is problem in parameters');
    }
    try {
      if (image != null) {
        emit(UpdateProfileImageLoading());
        // String imageName = basename(image.path);
        Reference refStorage = FirebaseStorage.instance
            .ref('image/${currentUser?.uid}/profile_image');

        File imageFile = File(image.path);
        await refStorage.putFile(imageFile);
        userModel?.image = await getImageProfile();
        UserService.updateUserInformation(userModel: userModel!);
        emit(UpdateProfileImageSuccessfully());
      } else {
        ToastHelper.toastfailure(msg: 'Please Choose Image');
      }
    } catch (e) {
      emit(UpdateProfileImageFailed(e.toString()));
    }
  }

  Future<void> refreshScreen() async {
    try {
      emit(GetNoteLoading());
      await Future.delayed(const Duration(seconds: 1), () => getNotes());
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
    }
  }
}
