import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  static UserModel? listUserModel;
  static Future createUserInformation({required UserModel userModel}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(userModel.toJson());
  }

  static Future<UserModel?> getUserInformation() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('user')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    var listDocs = querySnapshot.docs;
    if (listDocs.length > 0) {
      for (int i = 0; i < listDocs.length; i++) {
        listUserModel = UserModel.fromJson(
            jsonData: listDocs[i].data(), userId: listDocs[i].id);
      }
    }
    return listUserModel;
  }

  static Future updateUserInformation({required UserModel userModel}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userModel.userId)
        .update(userModel.toJson());
  }
}
