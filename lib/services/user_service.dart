import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

import '../helper/toast_helper.dart';

class UserService {
  static List<UserModel> listUserModel = [];
  static Future uploadUserInformation({required UserModel userModel}) async {
    await FirebaseFirestore.instance.collection('user').add(userModel.toJson());
  }

  static Future<List<UserModel>> getUserInformation() async {
    listUserModel = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('user')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    var listDocs = querySnapshot.docs;
    if (listDocs.length > 0) {
      for (int i = 0; i < listDocs.length; i++) {
        listUserModel.add(UserModel.fromJson(
            jsonData: listDocs[i].data(), userId: listDocs[i].id));
      }
    }
    return listUserModel;
  }
}
