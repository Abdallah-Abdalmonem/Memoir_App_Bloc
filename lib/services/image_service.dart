import 'package:image_picker/image_picker.dart';

class ImageServices {
  static ImagePicker? imagePicker;

  static Future<XFile?>? pickImageFromCamera() async {
    imagePicker = ImagePicker();
    return await imagePicker?.pickImage(source: ImageSource.camera);
  }

  static Future<XFile?>? pickImageFromGallery() async {
    imagePicker = ImagePicker();
    return await imagePicker?.pickImage(source: ImageSource.gallery);
  }
}
