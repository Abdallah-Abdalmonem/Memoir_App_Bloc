import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/toast_helper.dart';
import '../models/note_model.dart';

class NoteService {
  static List<NoteModel> listNoteModel = [];

  static Future<DocumentReference<Map<String, dynamic>>> addNote({
    required NoteModel noteModel,
  }) async {
    DocumentReference<Map<String, dynamic>> response;
    response = await FirebaseFirestore.instance
        .collection('Note')
        .add(noteModel.toJson());
    ToastHelper.toastSuccess(msg: 'add success');
    return response;
  }

  static Future<List<NoteModel>> getNotes() async {
    listNoteModel = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('Note')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    var listDocs = querySnapshot.docs;
    if (listDocs.length > 0) {
      for (int i = 0; i < listDocs.length; i++) {
        listNoteModel.add(NoteModel.formJson(
            jsonData: listDocs[i].data(), noteId: listDocs[i].id));
      }
    }
    return listNoteModel;
  }

  static Future<void> deleteNote(String noteId) async {
    try {
      FirebaseFirestore.instance.collection('Note').doc(noteId).delete();
      ToastHelper.toastSuccess(msg: 'delete success');
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
      print(e);
    }
  }

  static Future deleteAllNote() async {
    try {
      final instance = FirebaseFirestore.instance;
      final batch = instance.batch();
      var collection = instance.collection('Note');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
      print(e);
    }
  }

  static Future editNote({
    required NoteModel noteModel,
    // ممكن استخدم  الموديل اللى بيرجع ماب بدل الموديل وابعته على طول بدل السطر 91
    required String noteId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('Note')
          .doc(noteId)
          .update(noteModel.toJson());

      ToastHelper.toastSuccess(msg: 'edit success');
    } catch (e) {
      ToastHelper.toastfailure(msg: e.toString());
      print(e);
    }
  }
}
