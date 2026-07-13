// import 'package:flutter/material.dart';
// import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';


// class StartListening extends StatefulWidget {
//   final String image;
//   final String bookName;
  
//   const StartListening(
//       {super.key,
//       this.image = 'assets/books/book9.png',
//       this.bookName = 'Harry Potter and The Philosopher’s Stone',
//       });
//   static const String routeName = '/startListening';

//   @override
//   State<StartListening> createState() => _StartListeningState();
// }

// class _StartListeningState extends State<StartListening> {
//   double? height;
//   double? width;
//   double currentplay = 0.01;
//   double volume = 100;
//   double volumeBoost = 30;
//   String chapter = 'The Boy Who Lived';
//   int isPlay = 0;
//   bool isTap = true;

//   final chapterList = [
//     {
//       'name': 'The Boy Who Lived',
//       'time': '15:49 mins',
//     },
//     {
//       'name': 'The Vanishing Glass',
//       'time': '10:17 mins',
//     },
//     {
//       'name': 'The Keeper of Keys',
//       'time': '12:10 mins',
//     },
//     {
//       'name': 'Diagon Alley',
//       'time': '14:05 mins',
//     },
//     {
//       'name': 'The Journey from Platform Nine and Three-Quarters',
//       'time': '15:15 mins',
//     },
//     {
//       'name': 'The Sorting Hat',
//       'time': '12:10 mins',
//     },
//     {
//       'name': 'The Potions Master',
//       'time': '16:12 mins',
//     },
//     {
//       'name': 'The Midnight Duel',
//       'time': '17:10 mins',
//     },
//     {
//       'name': 'Hallowe\'en',
//       'time': '19:20 mins',
//     },
//     {
//       'name': 'Quidditch',
//       'time': '12:30 mins',
//     },
//     {
//       'name': 'The Mirror of Erised',
//       'time': '15:49 mins',
//     },
//     {
//       'name': 'Nicolas Flamel',
//       'time': '14:20 mins',
//     },
//     {
//       'name': 'Norbert the Norwegian Ridgeback',
//       'time': '17:10 mins',
//     },
//     {
//       'name': 'The Forbidden Forest',
//       'time': '11:10 mins',
//     },
//     {
//       'name': 'Through the Trapdoor',
//       'time': '09:15 mins',
//     },
//     {
//       'name': 'The Man with Two Faces',
//       'time': '10:30 mins',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     height = MediaQuery.of(context).size.height;
//     width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         titleSpacing: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Image.asset(
//             Assets.backButtonIconImage,
//             color: whiteColor,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           bookInfo(),
//           currentPlaying(),
//           chapters(),
//         ],
//       ),
//     );
//   }

//   bookInfo() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(
//         fixPadding * 2.0,
//         fixPadding * 2.0,
//         fixPadding * 2.0,
//         fixPadding * 1.7,
//       ),
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: height! * 0.24,
//               width: width! * 0.35,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 image: DecorationImage(
//                   image: AssetImage(widget.image),
//                   fit: BoxFit.cover,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     offset: const Offset(0, 3),
//                     color: blackColor.withValues(alpha: 0.1),
//                     spreadRadius: 2,
//                     blurRadius: 2,
//                   ),
//                 ],
//               ),
//             ),
//             heightSpace,
//             heightSpace,
//             heightSpace,
//             Text(
//               widget.bookName,
//               style: black16MediumTextStyle,
//             ),
            
//             heightSpace,
//             heightSpace,
//             heightSpace,
//             heightSpace,
//             Text(
//               'Chapter ${isPlay + 1}: $chapter',
//               textAlign: TextAlign.center,
//               style: black16RegularTextStyle,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   currentPlaying() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 children: [
//                   InkWell(
//                     onTap: () => volumeOption(),
//                     child: const Icon(
//                       Icons.volume_up,
//                       color: blackColor,
//                       size: 22,
//                     ),
//                   ),
//                   heightSpace,
//                   Text(
//                     '00:01',
//                     style: grey12RegularTextStyle,
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   InkWell(
//                     onTap: () => sleepTime(),
//                     child: const Icon(
//                       Icons.snooze,
//                       color: blackColor,
//                       size: 22,
//                     ),
//                   ),
//                   heightSpace,
//                   Text(
//                     '-15:48',
//                     style: grey12RegularTextStyle,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SliderTheme(
//             data: const SliderThemeData(
//               trackHeight: 2.4,
//               thumbShape: RoundSliderThumbShape(
//                   enabledThumbRadius: 7, disabledThumbRadius: 7),
//               overlayShape: RoundSliderOverlayShape(overlayRadius: 5),
//               valueIndicatorColor: primaryColor,
//             ),
//             child: Slider(
//               activeColor: primaryColor,
//               inactiveColor: greyColor.withValues(alpha: 0.3),
//               value: currentplay,
//               min: 0,
//               max: 15.49,
//               divisions: 200,
//               label: currentplay.toStringAsFixed(2),
//               onChanged: (double value) {
//                 setState(() {
//                   currentplay = value;
//                 });
//               },
//             ),
//           ),
//           heightSpace,
//           heightSpace,
//           heightSpace,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 height: 30,
//                 width: 30,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.skip_previous,
//                   color: whiteColor,
//                   size: 20,
//                 ),
//               ),
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               Container(
//                 height: 30,
//                 width: 30,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.replay_10,
//                   color: whiteColor,
//                   size: 20,
//                 ),
//               ),
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               InkWell(
//                 borderRadius: BorderRadius.circular(25),
//                 onTap: () {
//                   setState(() {
//                     isTap = !isTap;
//                   });
//                 },
//                 child: Icon(
//                   isTap ? Icons.play_circle : Icons.pause_circle,
//                   color: primaryColor,
//                   size: 50,
//                 ),
//               ),
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               Container(
//                 height: 30,
//                 width: 30,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.forward_10,
//                   color: whiteColor,
//                   size: 20,
//                 ),
//               ),
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               widthSpace,
//               Container(
//                 height: 30,
//                 width: 30,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.skip_next,
//                   color: whiteColor,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           heightSpace,
//           heightSpace,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 constraints: const BoxConstraints(maxWidth: 250),
//                 child: Text(
//                   'Chapter ${isPlay + 1}: $chapter',
//                   textAlign: TextAlign.end,
//                   overflow: TextOverflow.ellipsis,
//                   style: black14RegularTextStyle,
//                 ),
//               ),
//               widthSpace,
//               widthSpace,
//               const Icon(
//                 Icons.keyboard_arrow_down,
//                 color: primaryColor,
//                 size: 24,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   chapters() {
//     return Expanded(
//       child: ListView.builder(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(fixPadding * 2.0),
//         itemCount: chapterList.length,
//         itemBuilder: (context, index) {
//           final item = chapterList[index];
//           return Padding(
//             padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
//             child: InkWell(
//               onTap: () {
//                 setState(() {
//                   isPlay = index;
//                   chapter = item['name']!;
//                 });
//               },
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${index + 1}.',
//                         style: primaryColor14RegularTextStyle,
//                       ),
//                       widthSpace,
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['name']!,
//                               style: isPlay == index
//                                   ? primaryColor14RegularTextStyle
//                                   : black14RegularTextStyle,
//                             ),
//                             const SizedBox(height: 3),
//                             Text(
//                               item['time']!,
//                               style: grey12RegularTextStyle,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         isPlay == index
//                             ? Icons.pause_circle
//                             : Icons.play_circle,
//                         color: primaryColor,
//                         size: 18,
//                       ),
//                     ],
//                   ),
//                   divider(),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   volumeOption() {
//     return showModalBottomSheet(
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10),
//             topRight: Radius.circular(10),
//           ),
//         ),
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return Wrap(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(fixPadding * 2.0),
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Adjust Volume & Volume Boost',
//                             style: black16MediumTextStyle,
//                           ),
//                           InkWell(
//                             onTap: () => Navigator.pop(context),
//                             child: const Icon(
//                               Icons.close,
//                               color: blackColor,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.volume_up,
//                             size: 18,
//                             color: blackColor,
//                           ),
//                           widthSpace,
//                           Text(
//                             'Volume',
//                             style: black14RegularTextStyle,
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${volume.round()}%',
//                             style: black14RegularTextStyle,
//                           ),
//                         ],
//                       ),
//                       SliderTheme(
//                         data: const SliderThemeData(
//                           trackHeight: 2.4,
//                           thumbShape: RoundSliderThumbShape(
//                             enabledThumbRadius: 7,
//                             disabledThumbRadius: 7,
//                           ),
//                           overlayShape:
//                               RoundSliderOverlayShape(overlayRadius: 5),
//                           valueIndicatorColor: primaryColor,
//                         ),
//                         child: Slider(
//                           activeColor: primaryColor,
//                           inactiveColor: greyColor.withValues(alpha: 0.3),
//                           value: volume,
//                           min: 0,
//                           max: 100,
//                           divisions: 100,
//                           label: volume.round().toString(),
//                           onChanged: (double value) {
//                             setState(() {
//                               volume = value;
//                             });
//                           },
//                         ),
//                       ),
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.volume_up,
//                             size: 18,
//                             color: blackColor,
//                           ),
//                           widthSpace,
//                           Text(
//                             'Volume Boost',
//                             style: black14RegularTextStyle,
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${volumeBoost.round()}%',
//                             style: black14RegularTextStyle,
//                           ),
//                         ],
//                       ),
//                       SliderTheme(
//                         data: const SliderThemeData(
//                           trackHeight: 2.4,
//                           thumbShape: RoundSliderThumbShape(
//                             enabledThumbRadius: 7,
//                             disabledThumbRadius: 7,
//                           ),
//                           overlayShape:
//                               RoundSliderOverlayShape(overlayRadius: 5),
//                           valueIndicatorColor: primaryColor,
//                         ),
//                         child: Slider(
//                           activeColor: primaryColor,
//                           inactiveColor: greyColor.withValues(alpha: 0.3),
//                           value: volumeBoost,
//                           min: 0,
//                           max: 100,
//                           divisions: 100,
//                           label: volumeBoost.round().toString(),
//                           onChanged: (double value) {
//                             setState(() {
//                               volumeBoost = value;
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           });
//         });
//   }

//   sleepTime() {
//     return showModalBottomSheet(
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10),
//             topRight: Radius.circular(10),
//           ),
//         ),
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return Wrap(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(fixPadding * 2.0),
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sleep Time',
//                         style: black16MediumTextStyle,
//                       ),
//                       Text(
//                         'Automatically stop playing after:',
//                         style: grey14RegularTextStyle,
//                       ),
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'hr',
//                             style: black14RegularTextStyle,
//                           ),
//                           TimePickerSpinner(
//                             isShowSeconds: false,
//                             isForce2Digits: true,
//                             minutesInterval: 5,
//                             itemHeight: 25,
//                             time: DateTime(2021, 10, 22, 0, 10),
//                             highlightedTextStyle: primaryColor16MediumTextStyle,
//                             normalTextStyle: TextStyle(
//                               color: primaryColor.withValues(alpha: 0.5),
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           widthSpace,
//                           widthSpace,
//                           widthSpace,
//                           widthSpace,
//                           widthSpace,
//                           Text(
//                             'min',
//                             style: black14RegularTextStyle,
//                           ),
//                         ],
//                       ),
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       heightSpace,
//                       Row(
//                         children: [
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(5),
//                               onTap: () => Navigator.pop(context),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: fixPadding * 1.5),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: whiteColor,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: blackColor.withValues(alpha: 0.1),
//                                       spreadRadius: 1,
//                                       blurRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Text(
//                                   'Cancel',
//                                   style: primaryColor18SemiBoldTextStyle,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           widthSpace,
//                           widthSpace,
//                           Expanded(
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(5),
//                               onTap: () => Navigator.pop(context),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: fixPadding * 1.5),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: primaryColor,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color:
//                                           primaryColor.withValues(alpha: 0.3),
//                                       spreadRadius: 1,
//                                       blurRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Text(
//                                   'Confirm',
//                                   style: white18SemiBoldTextStyle,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           });
//         });
//   }

//   divider() {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       color: greyColor.withValues(alpha: 0.5),
//       height: 1,
//       width: double.infinity,
//     );
//   }
// }
