import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constant/app_image.dart';

class ImageScreen extends StatelessWidget {
  ImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? image = ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30)),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: image == null
                  ? Image.asset(AppImage.icon, fit: BoxFit.cover)
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                    )),
        ],
      ),
    );
  }
}
