import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/constant/app_routes.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';
import 'package:memoir_app_bloc/features/widgets/custom_button.dart';
import 'package:memoir_app_bloc/features/widgets/custom_select_color.dart';
import 'package:memoir_app_bloc/features/widgets/custom_textfield.dart';

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
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTitle(),
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
            buildNoteContent(),
            const SizedBox(height: 2),
            const Divider(color: Colors.white),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildFavoriteIcon(),
                buildDateTime(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconButton buildFavoriteIcon() {
    return IconButton(
      onPressed: () async {
        await cubit.changeFavorite(
            noteId: cubit.notesList[index].noteId.toString(),
            isFavoriteOld: cubit.isFavorite =
                !cubit.notesList[index].isFavorite!);
      },
      icon: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => Icon(
          Icons.favorite,
          color: cubit.notesList[index].isFavorite! ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Text buildDateTime() {
    return Text(
      '${cubit.notesList[index].createdOn?.toDate().year}-${cubit.notesList[index].createdOn?.toDate().month}-${cubit.notesList[index].createdOn?.toDate().day}\n${cubit.notesList[index].createdOn?.toDate().hour}:${cubit.notesList[index].createdOn?.toDate().minute}:${cubit.notesList[index].createdOn?.toDate().second}',
      maxLines: 2,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14,
        letterSpacing: 1,
        color: listTileColor == Colors.black ? Colors.white : Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Text buildNoteContent() {
    return Text('${cubit.notesList[index].note}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          wordSpacing: 2,
          color: listTileColor == Colors.black ? Colors.white : Colors.black,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 10);
  }

  Expanded buildTitle() {
    return Expanded(
      flex: 4,
      child: Text(
        '${cubit.notesList[index].title}',
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            wordSpacing: 2,
            color: listTileColor == Colors.black ? Colors.white : Colors.white,
            overflow: TextOverflow.ellipsis),
        maxLines: 2,
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
              if (value.isEmpty || value == '') {
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
              if (value.isEmpty || value == '') {
                editNoteEditingController.text =
                    '${cubit.notesList[index].note}';
              } else {
                editNoteEditingController.text = value;
              }
            },
          ),
          const SizedBox(height: 20),
          buildListColor(selectColor),
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

  SizedBox buildListColor(ValueNotifier<Color> selectColor) {
    return SizedBox(
      height: 100,
      width: 100,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: cubit.colorList.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
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
    );
  }

  void deleteNote(HomeCubit cubit) {
    cubit.deleteNote('${cubit.notesList[index].noteId}');
  }
}
