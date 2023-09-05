// import 'package:flutter/material.dart';

// import '../../controllers/home_controller.dart';

// class CustomSelectColorBuilder extends StatelessWidget {
//   CustomSelectColorBuilder({
//     super.key,
//     required this.controller,
//   });

//   final HomeController controller;
//   late ValueNotifier<Color> selectColor1;
//   @override
//   Widget build(BuildContext context) {
//     selectColor1 = ValueNotifier<Color>(controller.selectedColor);
//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 5,
//         ),
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.colorList.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//               onTap: () {
//                 controller.selectedColor = controller.colorList[index];
//                 selectColor1.value = controller.colorList[index];
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: CustomCircleAvatar(
//                     index: index,
//                     selectColor: selectColor1,
//                     colorList: controller.colorList),
//               ));
//         },
//       ),
//     );
//   }
// }

// class CustomCircleAvatar extends StatelessWidget {
//   CustomCircleAvatar({
//     required this.index,
//     required this.selectColor,
//     required this.colorList,
//     super.key,
//   });
//   int index;
//   ValueNotifier<Color> selectColor;
//   List colorList;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: selectColor,
//       builder: (context, value, child) => CircleAvatar(
//         radius: 40,
//         backgroundColor: colorList[index],
//         child: selectColor.value == colorList[index]
//             ? CircleAvatar(
//                 radius: 40,
//                 backgroundColor: Colors.grey.withAlpha(100),
//                 child: const Icon(Icons.check, color: Colors.white),
//               )
//             : null,
//       ),
//     );
//   }
// }
