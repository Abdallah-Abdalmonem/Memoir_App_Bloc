import 'package:shared_preferences/shared_preferences.dart';

import '../constant/app_image.dart';
import '../constant/app_keys.dart';

class CacheHelper {
  static SharedPreferences? prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future setProfileImageTemp() async {
    await CacheHelper.prefs
        ?.setString('image_profile_temp', AppImage.icon.toString());
  }

  static String? getProfileImageTemp() {
    return CacheHelper.prefs?.getString('image_profile_temp');
  }
}
