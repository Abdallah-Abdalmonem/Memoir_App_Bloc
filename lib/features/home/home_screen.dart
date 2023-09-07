import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';
import 'package:memoir_app_bloc/helper/custom_snackbar.dart';

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
    final cubit = BlocProvider.of<HomeCubit>(context)..loadUser();
    return Scaffold(
        drawer: drawerBuilder(cubit, context),
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
                    child: BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            const SizedBox(height: 10),
                            CustomTextFormField(
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
                            BlocConsumer<HomeCubit, HomeState>(
                              listener: (context, state) {
                                if (state is AddNoteSuccessfully) {
                                  titleEditingController.clear();
                                  noteEditingController.clear();
                                }
                              },
                              builder: (context, state) {
                                if (state is AddNoteLoading) {
                                  return const CircularProgressIndicator
                                      .adaptive();
                                }
                                return ElevatedButton(
                                  onPressed: () async {
                                    if (homeKey.currentState!.validate()) {
                                      await cubit.addNote(
                                          title: titleEditingController
                                                  .text.isEmpty
                                              ? 'No Title'
                                              : titleEditingController.text,
                                          note: noteEditingController.text);
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }
                                  },
                                  child: const Text('Add Note'),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            if (state is GetNoteSuccessfully)
                              viewGridView(state.notesList, cubit),
                            if (state is GetZeroNoteSuccessfully)
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(AppImage.icon, scale: 2),
                                    const SizedBox(height: 5),
                                    const Text('There is no notes',
                                        textScaleFactor: 1.5)
                                  ],
                                ),
                              ),
                            if (state is GetNoteLoading)
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 2,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (state is GetNoteFailed)
                              const Center(
                                child: Text('Error!!',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.red)),
                              ),
                          ],
                        );
                      },
                    ))),
          ),
        ));
  }
}

AppBar appBarBuilder(HomeCubit cubit, BuildContext context) {
  return AppBar(
      leading: Builder(builder: (context) {
        return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip);
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
            Navigator.of(context).pushNamed(AppRoutes.favoriteScreen);
          },
          icon: const Icon(Icons.favorite, color: Colors.red),
        ),
        IconButton(
          onPressed: () async {
            await showSearch(
                context: context,
                delegate: CustomSearchDelegate(notesList: cubit.notesList));
          },
          icon: const Icon(Icons.search, color: Colors.black),
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) async {
            switch (value) {
              case 'deleteAll':
                await cubit.deleteAllNote();
                break;
              case 'refresh_all_data':
                await cubit.refreshScreen();
                break;
              case 'refresh_notes':
                await cubit.refreshScreen();
                break;
              default:
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'deleteAll', child: Text("Delete All")),
            PopupMenuItem(
                value: 'refresh_all_data', child: Text("Refresh All Data")),
            PopupMenuItem(value: 'refresh_notes', child: Text("Refresh Notes"))
          ],
        )
      ]);
}

Drawer drawerBuilder(HomeCubit cubit, BuildContext context) {
  // final cubit = BlocProvider.of<HomeCubit>(context);
  return Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppImage.backgroundAuth),
          )),
          child: GestureDetector(
            onLongPress: () async {
              if (cubit.userModel?.image != null &&
                  cubit.signinWithEmailAndPassword) {
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
                    msg: 'You should choose photo to delete it');
              } else {
                ToastHelper.toastfailure(
                    msg: 'You should signin without gmail');
              }
            },
            onTap: () async {
              if (cubit.currentUser?.photoURL != null) {
                // signin with gmail
                Navigator.of(context).pushNamed(AppRoutes.imageScreen,
                    arguments: cubit.currentUser!.photoURL);
              }
              if (cubit.userModel?.image != null &&
                  cubit.signinWithEmailAndPassword) {
                // there is image
                Navigator.of(context).pushNamed(AppRoutes.imageScreen,
                    arguments: cubit.userModel?.image);
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
                  if (state is GetProfileImageLoading ||
                      state is RemoveProfileImageLoading ||
                      state is UpdateProfileImageLoading) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return CircleAvatar(
                      radius: double.infinity,
                      backgroundImage:
                          // login with email and password and image not found
                          cubit.signinWithEmailAndPassword &&
                                  // cubit.userModel?.image == '' ||
                                  cubit.userModel?.image == null
                              ? const AssetImage(AppImage.icon)
                              // there is image
                              : cubit.signinWithEmailAndPassword &&
                                      cubit.userModel?.image != null
                                  ? NetworkImage(cubit.userModel!.image!)
                                      as ImageProvider<Object>?
                                  // if sign with gmail
                                  : Image.network(FirebaseAuth
                                          .instance.currentUser!.photoURL!)
                                      .image,
                      // view camera for signin with email&password
                      child: cubit.signinWithEmailAndPassword
                          ? viewCamera(cubit, context)
                          : null);
                },
              ),
            ),
          ),
        ),
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is UpdateProfileImageLoading ||
                state is RemoveProfileImageLoading) {
              ToastHelper.toastSuccess(msg: 'Please wait..');
            }
            if (state is UpdateProfileImageSuccessfully) {
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shadowColor: Colors.purpleAccent,
                  elevation: 8,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          if (state is GetUserInformationLoading) {
                            const Text('Loading ...');
                          }
                          return Wrap(
                            children: [
                              const Text(
                                  textScaleFactor: 1.2,
                                  'Name: ',
                                  style: TextStyle(fontSize: 20)),
                              Text(
                                  textScaleFactor: 1.2,
                                  '${cubit.userModel?.displayName ?? cubit.currentUser?.displayName}',
                                  style: const TextStyle(fontSize: 20)),
                            ],
                          );
                        },
                      )),
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
                        child: BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            if (state is GetUserInformationLoading) {
                              const Text('Loading ...');
                            }
                            return Wrap(
                              children: [
                                const Text(
                                    textScaleFactor: 1.2,
                                    'Email: ',
                                    style: TextStyle(fontSize: 20)),
                                Text(
                                    textScaleFactor: 1.2,
                                    '${cubit.userModel?.email ?? cubit.currentUser?.email}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 20))
                              ],
                            );
                          },
                        ),
                      ))),
            ],
          ),
        ),
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
              });
            },
          ),
        ),
        const Spacer()
      ],
    ),
  );
}

viewCamera(HomeCubit cubit, BuildContext context) {
  bool isDismiss = true;
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
                  isDismissible: isDismiss,
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
                              await cubit.updateProfileImage(
                                fromWhat: 'gallery',
                              );
                              isDismiss = false;
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
                              await cubit.updateProfileImage(
                                  fromWhat: 'camera');
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

MasonryGridView viewGridView(List<NoteModel>? noteList, HomeCubit cubit) {
  return MasonryGridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: noteList?.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisSpacing: 16,
      mainAxisSpacing: 20,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      itemBuilder: (context, index) => CustomListTile(
          listTileColor: Color(int.parse('${noteList?[index].color}')),
          cubit: cubit,
          index: index));
}

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.listTileColor,
      required this.cubit,
      required this.index});

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
                maxLines: 10),
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

    cubit.editColor = cubit.colorList[index];
    ValueNotifier<Color> selectColor =
        ValueNotifier<Color>(cubit.selectedColor);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(15),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Edit Note',
              style: TextStyle(
                fontSize: 26,
                decoration: TextDecoration.underline,
              ),
            ),
            const Spacer(),
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.clear))
          ],
        ),
        children: [
          CustomTextFormField(
            initialValue: cubit.notesList[index].title,
            onChange: (value) {
              if (value.isEmpty || value == null || value == '') {
                editTitleEditingController.text =
                    '${cubit.notesList[index].title}';
              } else {
                editTitleEditingController.text = value;
              }
            },
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            maxLines: 10,
            initialValue: cubit.notesList[index].note,
            onChange: (value) {
              if (value.isEmpty || value == null || value == '') {
                editNoteEditingController.text =
                    '${cubit.notesList[index].note}';
              } else {
                editNoteEditingController.text = value;
              }
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            width: 100,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cubit.colorList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  cubit.editColor = cubit.colorList[index];
                  selectColor.value = cubit.colorList[index];
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: CustomCircleAvatar(
                    index: index,
                    selectColor: selectColor,
                    colorList: cubit.colorList,
                  ),
                ),
              ),
            ),
          ),
          BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state is EditNoteSuccessfully) {
                editTitleEditingController.clear();
                editNoteEditingController.clear();
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              if (state is EditNoteLoading) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              return CustomButton(
                  onPressed: () async {
                    await cubit.editNote(
                        oldNoteModel: cubit.notesList[index],
                        editTitle: editTitleEditingController.text,
                        editNote: editNoteEditingController.text);
                  },
                  textButton: 'Save Changes');
            },
          ),
        ],
      ),
    );
  }

  void deleteNote(HomeCubit cubit) {
    cubit.deleteNote('${cubit.notesList[index].noteId}');
  }
}
