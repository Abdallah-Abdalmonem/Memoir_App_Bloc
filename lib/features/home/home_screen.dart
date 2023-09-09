import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';
import 'package:memoir_app_bloc/features/widgets/custom_listTile.dart';

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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                          sizeHeight: 40,
                          maxLines: 10,
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
                            return const CircularProgressIndicator.adaptive();
                          }
                          return buildAddNoteButton(cubit);
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
                              style:
                                  TextStyle(fontSize: 24, color: Colors.red)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildAddNoteButton(HomeCubit cubit) {
    return ElevatedButton(
      onPressed: () async {
        if (homeKey.currentState!.validate()) {
          await cubit.addNote(
              title: titleEditingController.text.isEmpty
                  ? 'No Title'
                  : titleEditingController.text,
              note: noteEditingController.text);
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: const Text('Add Note'),
    );
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
            Navigator.pushNamed(context, AppRoutes.favoriteScreen);
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
                              },
                            ),
                            CustomButton(
                              textButton: 'Cancel',
                              colorText: Colors.black,
                              colorButton: Colors.white,
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          ],
                        ));
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
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              textScaleFactor: 1.2,
                              '${cubit.userModel?.displayName ?? cubit.currentUser?.displayName}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        );
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
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
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
