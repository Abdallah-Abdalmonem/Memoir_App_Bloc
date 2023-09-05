// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../models/user_model.dart';
// import '../services/user_service.dart';
// import '../constant/app_keys.dart';
// import '../helper/cache_helper.dart';
// import '../services/image_service.dart';
// import 'package:path/path.dart';
// import 'package:flutter/material.dart';
// import '../helper/toast_helper.dart';
// import '../models/note_model.dart';
// import '../services/note_service.dart';

// import 'package:image_picker/image_picker.dart';

// class HomeController extends GetxController {
//   @override
//   void onInit() {
//     titleEditingController = TextEditingController();
//     noteEditingController = TextEditingController();

//     editTitleEditingController = TextEditingController();
//     editNoteEditingController = TextEditingController();
//     super.onInit();
//   }

//   @override
//   void dispose() {
//     titleEditingController.dispose();
//     noteEditingController.dispose();

//     editTitleEditingController.dispose();
//     editNoteEditingController.dispose();
//     homeKey.currentState?.dispose();
//     super.dispose();
//   }

//   @override
//   void onClose() {
//     Get.deleteAll();

//     super.onClose();
//   }
// }
