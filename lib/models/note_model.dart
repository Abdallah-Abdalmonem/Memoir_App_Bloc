import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String? userId;
  String? noteId;
  String? title;
  String? note;
  String? color;
  Timestamp? createdOn;
  Timestamp? editOn;
  NoteModel({
    this.userId,
    this.noteId,
    this.title,
    this.note,
    this.color,
    this.createdOn,
    this.editOn,
  }) {
    String tempString = this.color.toString();
    String color = '';
    for (int i = 6; i <= 15; i++) {
      color += tempString[i];
    }
    this.color = color;
  }

  NoteModel.formJson(
      {required Map<String, dynamic> jsonData, required String this.noteId}) {
    userId = jsonData['userId'];
    title = jsonData['title'];
    note = jsonData['note'];
    color = jsonData['color'];
    createdOn = jsonData['createdOn'];
    editOn = jsonData['editOn'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'noteId': noteId,
      'title': title,
      'note': note,
      'color': color,
      'createdOn': createdOn,
      'editOn': editOn,
    };
  }
}
