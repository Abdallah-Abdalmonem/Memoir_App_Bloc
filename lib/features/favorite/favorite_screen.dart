import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoir_app_bloc/constant/app_routes.dart';
import 'package:memoir_app_bloc/features/home/home_cubit/home_cubit.dart';
import 'package:memoir_app_bloc/features/widgets/custom_button.dart';
import 'package:memoir_app_bloc/features/widgets/custom_dialog.dart';
import 'package:memoir_app_bloc/helper/toast_helper.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => CustomDialog(
                  title: 'Are you sure to remove all notes from favorite?',
                  confirmFunction: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is DeleteFavoriteListLoading) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                        );
                      }
                      return CustomButton(
                        colorButton: Colors.red,
                        onPressed: () async {
                          await cubit.deleteFavoriteList();
                          Navigator.pop(context);
                        },
                        textButton: 'remove all',
                      );
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
        centerTitle: true,
        title: const Text('❤ f a v o r i t e ❤'),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
        if (cubit.favoriteNoteList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text('There are no favorite')],
            ),
          );
        }

        if (cubit.favoriteNoteList.isNotEmpty) {
          return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.noteScreen,
                          arguments: cubit.favoriteNoteList[index]);
                    },
                    child: ListTile(
                      hoverColor: Colors.amber,
                      contentPadding: const EdgeInsets.all(15),
                      title:
                          Text(cubit.favoriteNoteList[index].title.toString()),
                      subtitle:
                          Text(cubit.favoriteNoteList[index].note.toString()),
                      leading: IconButton(
                          onPressed: () {
                            cubit.changeFavorite(
                                noteId: cubit.favoriteNoteList[index].noteId
                                    .toString(),
                                isFavoriteOld:
                                    cubit.favoriteNoteList[index].isFavorite!);
                          },
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )),
                    ),
                  ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: cubit.favoriteNoteList.length);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator.adaptive()],
          ),
        );
      }),
    );
  }
}
