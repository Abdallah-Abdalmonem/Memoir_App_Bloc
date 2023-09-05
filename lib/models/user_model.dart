class UserModel {
  String? userId;
  String? displayName;
  String? email;
  String? image;
  UserModel({
    this.userId,
    this.displayName,
    this.email,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'image': image,
    };
  }

  UserModel.fromJson(
      {required Map<String, dynamic> jsonData, required String this.userId}) {
    displayName = jsonData['displayName'];
    email = jsonData['email'];
    image = jsonData['image'];
  }
}
