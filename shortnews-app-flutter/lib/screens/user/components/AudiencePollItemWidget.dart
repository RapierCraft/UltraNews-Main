// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import '/../models/AudiencePollModel.dart';
// import '/../screens/user/ViewPollDetailScreen.dart';
// import '/../services/PollAnswerListService.dart';
// import '/../utils/Colors.dart';
// import '/../utils/Common.dart';
// import '/../utils/Constants.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import '../../../main.dart';
//
// // ignore: must_be_immutable
// class AudiencePollItemWidget extends StatefulWidget {
//   final AudiencePollModel? model;
//
//   AudiencePollItemWidget({this.model});
//
//   @override
//   _AudiencePollItemWidgetState createState() => _AudiencePollItemWidgetState();
// }
//
// class _AudiencePollItemWidgetState extends State<AudiencePollItemWidget> {
//   late PollAnswerListService pollAnswerList;
//   List<UserData> userDataList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }
//
//   Future<void> init() async {
//     pollAnswerList = PollAnswerListService(pollID: widget.model!.id);
//
//     pollAnswerList.getAllPollAnswerList().listen((event) {
//       userDataList.clear();
//       userDataList.addAll(event);
//       setState(() {});
//     });
//   }
//
//   void addPollAnswer(String? answer) async {
//     UserData userData = UserData();
//     userData.pollAnswer = answer.validate();
//     userData.pollUserId = getStringAsync(USER_ID);
//     userData.pollUserName = getStringAsync(FULL_NAME);
//     userData.pollUserImage = getStringAsync(PROFILE_IMAGE);
//     userData.createdAt = DateTime.now();
//
//     await pollAnswerList.addDocument(userData.toJson()).then((value) {
//       init();
//     }).catchError((error) {
//       log(error.toString());
//
//       toast(error.toString());
//     });
//   }
//
//   @override
//   void setState(VoidCallback fn) {
//     if (mounted) super.setState(fn);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Observer(
//       builder: (_) => Container(
//         margin: EdgeInsets.all(8),
//         width: context.width() - 32,
//         decoration: boxDecorationDefault(color: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.model!.pollQuestion.validate(),
//               style: boldTextStyle(size: 18),
//             ).paddingSymmetric(vertical: 8, horizontal: 8),
//             Container(
//               width: context.width(),
//               padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//               child: Wrap(
//                 alignment: WrapAlignment.start,
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: widget.model!.pollTagsList.validate().map((e) {
//                   return Text(e.validate(), style: primaryTextStyle(color: Colors.blue, size: 12));
//                 }).toList(),
//               ),
//             ),
//             IgnorePointer(
//               ignoring: getBoolAsync(IS_LOGGED_IN) && !userDataList.any((e) => e.pollUserId == getStringAsync(USER_ID)) ? false : true,
//               child: Column(
//                 children: widget.model!.pollChoiceList.validate().map((e) {
//                   return Container(
//                     width: context.width(),
//                     height: 40,
//                     decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
//                     child: Stack(
//                       children: [
//                         Stack(
//                           children: [
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: Container(
//                                 width: context.width(),
//                                 child: Text(
//                                   e.validate(),
//                                   style: primaryTextStyle(weight: FontWeight.w700),
//                                   overflow: TextOverflow.ellipsis,
//                                 ).paddingSymmetric(horizontal: 4),
//                               ),
//                             ),
//                             userDataList.isNotEmpty && userDataList.any((e) => e.pollUserId == getStringAsync(USER_ID))
//                                 ? AnimatedContainer(
//                                     duration: Duration(milliseconds: 500),
//                                     width:
//                                         getPollPercentage(answerList: userDataList, answer: e.validate()) / 100.0 == 0.0 ? 0 : (context.width() * (getPollPercentage(answerList: userDataList, answer: e.validate()) / 100.0)) - 32,
//                                     color: Colors.green.withOpacity(0.5),
//                                   )
//                                 : SizedBox(),
//                           ],
//                         ),
//                         userDataList.isNotEmpty && userDataList.any((e) => e.pollUserId == getStringAsync(USER_ID))
//                             ? Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Container(
//                                   child: Text(
//                                     '${getPollPercentage(answerList: userDataList, answer: e.validate()).roundToDouble()} %',
//                                     style: boldTextStyle(),
//                                     overflow: TextOverflow.ellipsis,
//                                   ).paddingSymmetric(horizontal: 4),
//                                 ),
//                               )
//                             : SizedBox(),
//                       ],
//                     ),
//                   ).onTap(() {
//                     if (!widget.model!.endAt!.difference(DateTime.now()).isNegative) {
//                       addPollAnswer(e);
//                     }
//                   }).paddingSymmetric(vertical: 8, horizontal: 8);
//                 }).toList(),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(!getBoolAsync(IS_LOGGED_IN) || userDataList.any((e) => e.pollUserId == getStringAsync(USER_ID)) ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 16, color: Colors.grey),
//                 4.width,
//                 if (getBoolAsync(IS_LOGGED_IN) && userDataList.isNotEmpty && userDataList.any((e) => e.pollUserId == getStringAsync(USER_ID)))
//                   createRichText(
//                     list: [
//                       TextSpan(
//                         text: '${'total_votes'.translate} : ',
//                         style: secondaryTextStyle(size: 12),
//                       ),
//                       TextSpan(
//                         text: '${userDataList.length.validate()}',
//                         style: boldTextStyle(),
//                       )
//                     ],
//                   ).paddingOnly(left: 8, right: 8, bottom: 4).expand(),
//                 if (!getBoolAsync(IS_LOGGED_IN)) Text('sign_for_poll'.translate, style: secondaryTextStyle(size: 12)).expand(),
//                 Text('${widget.model!.createdAt!.timeAgo}', style: secondaryTextStyle(size: 10)),
//               ],
//             ).paddingSymmetric(vertical: 8, horizontal: 8),
//           ],
//         ),
//       ).onTap(() {
//         ViewPollDetailScreen(model: widget.model).launch(context);
//       }),
//     );
//   }
// }
