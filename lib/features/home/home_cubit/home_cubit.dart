import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  String? imageUrl;
  bool signinWithEmailAndPassword = false;

  onInit() {
    UserService.getUserInformation().then((value) {
      if (value.length > 0) {
        signinWithEmailAndPassword = true;
      }
    });
  }

  Future<String?> getImageProfile() async {
    try {
      emit(GetProfileImageLoading());
      Reference refStorage = FirebaseStorage.instance
          .ref('image/${currentUser?.uid}/profile_image');

      imageUrl = await refStorage.getDownloadURL();
      if (imageUrl != null) {
        return imageUrl;
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
      List<NoteModel> response = await NoteService.getNotes();
      notesList = response;

      if (response.length > 0) {
        print('get note');
        print(response.length);
        return response;
      }
      emit(GetNoteSuccessfully(response));
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
        title: note,
        note: note,
        color: selectedColor.toString(),
        createdOn: Timestamp.now(),
        userId: FirebaseAuth.instance.currentUser?.uid,
      );
      await NoteService.addNote(noteModel: noteModel).then((value) {
        emit(AddNoteSuccessfully());
      });
    } catch (e) {
      emit(AddNoteFailed(e.toString()));
      ToastHelper.toastfailure(msg: e.toString());
      print(e);
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      emit(DeleteNoteLoading());
      await NoteService.deleteNote(noteId);
      emit(DeleteNoteSuccessfully());
    } catch (e) {
      emit(DeleteNoteFailed(e.toString()));
    }
  }

  Future<void> deleteAllNote() async {
    try {
      if (notesList.isNotEmpty) {
        emit(DeleteNoteLoading());
        await NoteService.deleteAllNote();
        notesList.clear();
        // await getNotes();
        emit(DeleteNoteSuccessfully());
      } else {
        ToastHelper.toastfailure(msg: 'There is no notes');
      }
    } catch (e) {
      emit(DeleteNoteFailed(e.toString()));
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
        title: editTitle,
        note: editNote,
        color: editColor.toString(),
        createdOn: oldNoteModel.createdOn,
        editOn: Timestamp.now(),
      );
      await NoteService.editNote(
          noteId: oldNoteModel.noteId.toString(), noteModel: noteModel);
      emit(EditNoteSuccessfully());
    } catch (e) {
      emit(EditNoteFailed(e.toString()));
    }
  }

  Future removeProfileImage() async {
    try {
      if (imageUrl != null) {
        emit(RemoveProfileImageLoading());
        await FirebaseStorage.instance
            .ref('image/${currentUser?.uid}/profile_image')
            .delete();
        imageUrl = null;
        emit(RemoveProfileImageSuccessfully());
      }
    } catch (e) {
      emit(RemoveProfileImageFailed(e.toString()));
    }
  }

  uploadImage({required String fromWhat}) async {
    XFile? image;

    switch (fromWhat) {
      case 'camera':
        image = await ImageServices.pickImageFromCamera();
        break;
      case 'gallery':
        image = await ImageServices.pickImageFromGallery();
        break;
      default:
        print('user not select');
    }
    try {
      if (image != null) {
        emit(UploadProfileImageLoading());
        // String imageName = basename(image.path);
        Reference refStorage = FirebaseStorage.instance
            .ref('image/${currentUser?.uid}/profile_image');

        File imageFile = File(image.path);
        await refStorage.putFile(imageFile);
        await getImageProfile();
        emit(UploadProfileImageSuccessfully());
      } else {
        ToastHelper.toastfailure(msg: 'Please Choose Image');
      }
    } catch (e) {
      emit(UploadProfileImageFailed(e.toString()));
    }
  }

  Future<void> refreshScreen() async {
    try {
      emit(RefreshNoteLoading());
      await Future.delayed(const Duration(seconds: 2), () => getNotes());
      emit(RefreshNoteSuccessfully());
    } catch (e) {
      emit(RefreshNoteFailed(e.toString()));
    }
  }
}
