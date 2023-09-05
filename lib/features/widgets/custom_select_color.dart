import 'package:flutter/material.dart';

import '../home/home_cubit/home_cubit.dart';

class CustomSelectColorBuilder extends StatelessWidget {
  CustomSelectColorBuilder({
    super.key,
    // required this.controller,
  });

  // final HomeController controller;
  @override
  Widget build(BuildContext context) {
    // final cubit = BlocProvider.of<HomeCubit>(context);
    final cubit = HomeCubit.get(context);
    final ValueNotifier<Color> selectColor1 =
        ValueNotifier<Color>(cubit.selectedColor);
    return SizedBox(
      height: 100,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: cubit.colorList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                cubit.selectedColor = cubit.colorList[index];
                selectColor1.value = cubit.colorList[index];
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomCircleAvatar(
                    index: index,
                    selectColor: selectColor1,
                    colorList: cubit.colorList),
              ));
        },
      ),
    );
  }
}

class CustomCircleAvatar extends StatelessWidget {
  CustomCircleAvatar({
    required this.index,
    required this.selectColor,
    required this.colorList,
    super.key,
  });
  int index;
  ValueNotifier<Color> selectColor;
  List colorList;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectColor,
      builder: (context, value, child) => CircleAvatar(
        radius: 40,
        backgroundColor: colorList[index],
        child: selectColor.value == colorList[index]
            ? CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.withAlpha(100),
                child: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
