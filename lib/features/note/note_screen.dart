import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../constant/app_image.dart';
import '../../models/note_model.dart';

class NoteScreen extends StatelessWidget {
  NoteScreen({super.key});

  late final ValueNotifier<double> fontSizeTitle = ValueNotifier<double>(16);
  late final ValueNotifier<double> fontSizeNote = ValueNotifier<double>(16);

  @override
  Widget build(BuildContext context) {
    final NoteModel noteData =
        ModalRoute.of(context)!.settings.arguments as NoteModel;

    bool isArabic() {
      if (noteData.note![0].codeUnits[0] >= 0x0600 &&
          noteData.note![0].codeUnits[0] <= 0x06E0) {
        return true;
      }
      return false;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(int.parse('${noteData.color}')).withOpacity(.9),
      appBar: AppBar(
        leadingWidth: 30,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                          height: 400,
                          color: Colors.white,
                          child: Column(
                            children: [
                              const Spacer(),
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.black,
                                            radius: 30,
                                            child:
                                                ValueListenableBuilder<double>(
                                              valueListenable: fontSizeTitle,
                                              builder:
                                                  (context, value, child) =>
                                                      Text(
                                                '${fontSizeTitle.value.toInt()}',
                                                textScaleFactor: 2,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          const Text('Title Size'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ValueListenableBuilder<double>(
                                    valueListenable: fontSizeTitle,
                                    builder: (context, value, child) => Slider(
                                        max: 100,
                                        min: 10,
                                        value: fontSizeTitle.value,
                                        onChanged: (value) {
                                          fontSizeTitle.value = value;
                                        }),
                                  ),
                                  const Divider(),
                                  Column(
                                    children: [
                                      const Text('Note Size'),
                                      CircleAvatar(
                                        backgroundColor: Colors.black,
                                        radius: 30,
                                        child: ValueListenableBuilder<double>(
                                          valueListenable: fontSizeNote,
                                          builder: (context, value, child) =>
                                              Text(
                                            '${fontSizeNote.value.toInt()}',
                                            textScaleFactor: 2,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      ValueListenableBuilder<double>(
                                        valueListenable: fontSizeNote,
                                        builder: (context, value, child) =>
                                            Slider(
                                                max: 100,
                                                min: 10,
                                                value: fontSizeNote.value,
                                                onChanged: (value) {
                                                  fontSizeNote.value = value;
                                                }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ));
              },
              icon: const Icon(Icons.edit_outlined)),
          IconButton(
              onPressed: () async {
                await Share.share(noteData.note.toString(),
                    subject: noteData.note);
              },
              icon: const Icon(
                Icons.share,
                color: Colors.white,
              )),
        ],
        title: const Text(
          // '${noteData.title}',
          'My Note',
          style: TextStyle(
            letterSpacing: 1,
            overflow: TextOverflow.ellipsis,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppImage.backgroundAuth),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(.5),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: fontSizeTitle,
                      builder: (context, value, child) => SelectableText(
                        maxLines: null,
                        textDirection:
                            isArabic() ? TextDirection.rtl : TextDirection.ltr,
                        '${noteData.title}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: fontSizeTitle.value,
                            letterSpacing: 4,
                            wordSpacing: 3,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                    const Divider(),
                    ValueListenableBuilder<double>(
                      valueListenable: fontSizeNote,
                      builder: (context, value, child) => SelectableText(
                        maxLines: null,
                        textDirection:
                            isArabic() ? TextDirection.rtl : TextDirection.ltr,
                        '${noteData.note}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: fontSizeNote.value,
                            letterSpacing: 2,
                            wordSpacing: 3,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
