import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';

import '../../services/user_service.dart';
import '../../constant/app_image.dart';
import '../../constant/app_routes.dart';
import '../../helper/toast_helper.dart';
import '../../models/note_model.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_select_color.dart';
import '../widgets/custom_textfield.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../helper/cache_helper.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController noteEditingController = TextEditingController();

  GlobalKey<FormState> homeKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Scaffold(
        drawer: drawerBuilder(context),
        backgroundColor: Colors.white,
        appBar: appBarBuilder(cubit, context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              await cubit.refreshScreen();
            },
            child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Form(
                    key: homeKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        CustomTextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                titleEditingController.text = 'No Title';
                              }
                              return null;
                            },
                            hintText: 'Title',
                            textController: titleEditingController),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Can\'t be Empty';
                              }
                              return null;
                            },
                            sizeHeight: 30,
                            hintText: 'Note',
                            textController: noteEditingController),
                        CustomSelectColorBuilder(),
                        ElevatedButton(
                          onPressed: () async {
                            if (homeKey.currentState!.validate()) {
                              await cubit.addNote(
                                  title: titleEditingController.text,
                                  note: noteEditingController.text);

                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          child: const Text('Add Note'),
                        ),
                        const SizedBox(height: 6),
                        BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) => FutureBuilder(
                                future: cubit.getNotes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return viewGridView(snapshot, cubit);
                                  } else if (cubit.notesList.isEmpty) {
                                    return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(AppImage.icon,
                                                scale: 2),
                                            const SizedBox(height: 5),
                                            const Text('There is no notes',
                                                textScaleFactor: 1.5)
                                          ],
                                        ));
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        child: const Center(
                                            child:
                                                CircularProgressIndicator()));
                                  }
                                  return const Text('Error!!',
                                      style: TextStyle(
                                          fontSize: 24, color: Colors.red));
                                }))
                      ],
                    ))),
          ),
        ));
  }
}

AppBar appBarBuilder(HomeCubit cubit, BuildContext context) {
  return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      }),
      titleSpacing: 5,
      centerTitle: true,
      title: const Text('M e m o i r',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: CustomSearchDelegate(notesList: cubit.notesList),
              );
            },
            icon: const Icon(Icons.search, color: Colors.black)),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) async {
            switch (value) {
              case 'deleteAll':
                await cubit.deleteAllNote();
                break;
              case 'refresh':
                await cubit.refreshScreen();
                break;
              default:
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'deleteAll', child: Text("delete all")),
            PopupMenuItem(value: 'refresh', child: Text("refresh screen"))
          ],
        )
      ]);
}

Drawer drawerBuilder(BuildContext context) {
  final cubit = BlocProvider.of<HomeCubit>(context);
  return Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(AppImage.backgroundAuth))),
          child: GestureDetector(
            onLongPress: () async {
              if (cubit.imageUrl != null && cubit.signinWithEmailAndPassword) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Delete photo'),
                          content: const Text('Do you want to delete photo?'),
                          actions: [
                            CustomButton(
                                textButton: 'Delete',
                                colorButton: Colors.red,
                                onPressed: () async {
                                  await cubit.removeProfileImage().then(
                                      (value) => Navigator.of(context).pop());
                                }),
                            CustomButton(
                                textButton: 'Cancel',
                                colorText: Colors.black,
                                colorButton: Colors.white,
                                onPressed: () => Navigator.of(context).pop())
                          ],
                        )
                    // buttonColor: AppColor.primaryColor,
                    // cancelTextColor: Colors.red,
                    // confirmTextColor: Colors.white,
                    );
              } else if (cubit.signinWithEmailAndPassword) {
                ToastHelper.toastfailure(
                    msg: 'You should signin without gmail');
              } else {
                ToastHelper.toastfailure(
                    msg: 'You should choose photo to delete it');
              }
            },
            onTap: () async {
              if (FirebaseAuth.instance.currentUser?.photoURL != null) {
                // signin with gmail

                Navigator.of(context).pushNamed(AppRoutes.imageScreen,
                    arguments: FirebaseAuth.instance.currentUser!.photoURL);
              }
              if (cubit.imageUrl == null) {
              } else if (cubit.imageUrl != null &&
                  cubit.signinWithEmailAndPassword) {
                // there is image

                Navigator.of(context).pushNamed(AppRoutes.imageScreen,
                    arguments: cubit.imageUrl);
              } else {
                // default image

                Navigator.of(context)
                    .pushNamed(AppRoutes.imageScreen, arguments: null);
              }
            },
            child: CircleAvatar(
              radius: double.infinity,
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return FutureBuilder(
                      future: cubit.getImageProfile(),
                      builder: (context, snapshot) {
                        return CircleAvatar(
                            radius: double.infinity,
                            backgroundImage:
                                // image not found
                                snapshot.data == null &&
                                        cubit.signinWithEmailAndPassword
                                    ? const AssetImage(AppImage.icon)
                                    // there is image
                                    : snapshot.data != null &&
                                            cubit.signinWithEmailAndPassword
                                        ? NetworkImage(snapshot.data!)
                                            as ImageProvider<Object>?
                                        // if sign with gmail
                                        : Image.network(FirebaseAuth.instance
                                                .currentUser!.photoURL!)
                                            .image,
                            // view camera for signin with email&password
                            child: cubit.signinWithEmailAndPassword
                                ? viewCamera(cubit, context)
                                : null);
                      });
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            shadowColor: Colors.purpleAccent,
            elevation: 8,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: UserService.getUserInformation(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        textScaleFactor: 1.2,
                        'Name: ${cubit.signinWithEmailAndPassword ? snapshot.data[0].displayName : cubit.currentUser?.displayName}',
                        style: const TextStyle(fontSize: 20));
                  } else {
                    return const Text('Loading...');
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(
            width: double.infinity,
            child: Card(
                shadowColor: Colors.purpleAccent,
                margin: const EdgeInsets.all(8),
                elevation: 8,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        textScaleFactor: 1.2,
                        'Email:\n${cubit.currentUser?.email}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20))))),
        const SizedBox(height: 50),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('To delete your photo press on photo to 2 seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                shadows: [
                  Shadow(color: Colors.deepPurple, blurRadius: 1.5),
                  Shadow(color: Colors.red, blurRadius: 1.5),
                ],
              ),
              textScaleFactor: 1.3),
        ),
        const Spacer(flex: 5),
        Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButton(
            colorButton: Colors.red,
            textButton: 'log out',
            onPressed: () async {
              await CacheHelper.prefs?.clear().then((value) async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed(AppRoutes.signin);
                // controller.onClose();
              });
            },
          ),
        ),
        const Spacer()
      ],
    ),
  );
}

Column viewCamera(HomeCubit cubit, BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 15,
            child: InkWell(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ColoredBox(
                          color: Colors.grey,
                          child: IconButton(
                            iconSize: 50,
                            onPressed: () async {
                              await cubit.uploadImage(
                                fromWhat: 'gallery',
                              );
                            },
                            icon: const Icon(
                              Icons.photo,
                            ),
                          ),
                        ),
                        const VerticalDivider(
                            endIndent: 50, color: Colors.grey, indent: 50),
                        ColoredBox(
                          color: Colors.grey,
                          child: IconButton(
                            iconSize: 50,
                            onPressed: () async {
                              await cubit.uploadImage(fromWhat: 'camera');
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.photo_camera,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

MasonryGridView viewGridView(
    AsyncSnapshot<List<NoteModel>?> snapshot, HomeCubit cubit) {
  return MasonryGridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: snapshot.data?.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisSpacing: 16,
      mainAxisSpacing: 20,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemBuilder: (context, index) => CustomListTile(
          listTileColor: Color(int.parse('${snapshot.data?[index].color}')),
          cubit: cubit,
          index: index));
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.listTileColor,
    required this.cubit,
    required this.index,
  });

  final Color listTileColor;
  final HomeCubit cubit;
  final int index;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.pushNamed(context, AppRoutes.noteScreen,
            arguments: cubit.notesList[index]);
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15, top: 5),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: listTileColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.purple.withOpacity(.2),
                  spreadRadius: 2,
                  offset: const Offset(0, 3))
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 4,
                    child: Text('${cubit.notesList[index].title}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            wordSpacing: 2,
                            color: listTileColor == Colors.black
                                ? Colors.white
                                : Colors.white,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 2)),
                Expanded(
                  child: PopupMenuButton(
                    color: Colors.white,
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          editNote(context);
                          break;
                        case 'delete':
                          deleteNote(cubit);
                          break;
                        default:
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text("edit")),
                      PopupMenuItem(value: 'delete', child: Text("delete")),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white),
            const SizedBox(height: 10),
            Text('${cubit.notesList[index].note}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    wordSpacing: 2,
                    color: listTileColor == Colors.black
                        ? Colors.white
                        : Colors.black,
                    overflow: TextOverflow.ellipsis),
                maxLines: 8),
            const SizedBox(height: 2),
            const Divider(color: Colors.white),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${cubit.notesList[index].createdOn?.toDate().year}-${cubit.notesList[index].createdOn?.toDate().month}-${cubit.notesList[index].createdOn?.toDate().day}\n${cubit.notesList[index].createdOn?.toDate().hour}:${cubit.notesList[index].createdOn?.toDate().minute}:${cubit.notesList[index].createdOn?.toDate().second}',
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1,
                      color: listTileColor == Colors.black
                          ? Colors.white
                          : Colors.black,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void editNote(BuildContext context) {
    final TextEditingController editTitleEditingController =
        TextEditingController();
    final TextEditingController editNoteEditingController =
        TextEditingController();

    //  editTitleEditingController.text =
    //     '${controller.notesList[index].title}';
    // controller.editNoteEditingController.text =
    //     '${controller.notesList[index].note}';
    cubit.editColor = cubit.colorList[index];
    ValueNotifier<Color> selectColor =
        ValueNotifier<Color>(cubit.selectedColor);

    // Get.dialog(
    //   barrierDismissible: false,
    //   SimpleDialog(
    //     contentPadding: const EdgeInsets.all(15),
    //     title: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const Spacer(),
    //         const Text(
    //           'Edit Note',
    //           style: TextStyle(
    //             fontSize: 26,
    //             decoration: TextDecoration.underline,
    //           ),
    //         ),
    //         const Spacer(),
    //         InkWell(
    //             onTap: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: const Icon(Icons.clear))
    //       ],
    //     ),
    //     children: [
    //       CustomTextFormField(
    //         initialValue: controller.notesList[index].title,
    //         onChange: (value) {
    //           if (value.isEmpty || value == null || value == '') {
    //             controller.editTitleEditingController.text =
    //                 '${controller.notesList[index].title}';
    //           } else {
    //             controller.editTitleEditingController.text = value;
    //           }
    //         },
    //       ),
    //       const SizedBox(height: 20),
    //       CustomTextFormField(
    //           initialValue: controller.notesList[index].note,
    //           onChange: (value) {
    //             if (value.isEmpty || value == null || value == '') {
    //               controller.editNoteEditingController.text =
    //                   '${controller.notesList[index].note}';
    //             } else {
    //               controller.editNoteEditingController.text = value;
    //             }
    //           },
    //           maxLines: 10),
    //       const SizedBox(height: 20),
    //       SizedBox(
    //         height: 100,
    //         width: 100,
    //         child: GridView.builder(
    //           physics: const NeverScrollableScrollPhysics(),
    //           shrinkWrap: true,
    //           itemCount: cubit.colorList.length,
    //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //               crossAxisCount: 6),
    //           itemBuilder: (context, index) => GestureDetector(
    //             onTap: () {
    //               cubit.editColor = cubit.colorList[index];
    //               selectColor.value = cubit.colorList[index];
    //             },
    //             child: Container(
    //               color: Colors.white,
    //               padding: const EdgeInsets.all(8.0),
    //               child: CustomCircleAvatar(
    //                 index: index,
    //                 selectColor: selectColor,
    //                 colorList: cubit.colorList,
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       CustomButton(
    //           onPressed: () async {
    //             await cubit.editNote(cubit.notesList[index]);
    //             Navigator.of(context).pop();
    //           },
    //           textButton: 'Save Changes'),
    //     ],
    //   ),
    // );
  }

  void deleteNote(HomeCubit cubit) {
    cubit.deleteNote('${cubit.notesList[index].noteId}');
  }
}
