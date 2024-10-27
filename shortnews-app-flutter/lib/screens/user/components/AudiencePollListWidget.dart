// import 'package:flutter/material.dart';
// import '/../models/AudiencePollModel.dart';
// import 'package:nb_utils/nb_utils.dart';
//
// import 'AudiencePollItemWidget.dart';
//
// class AudiencePollListWidget extends StatefulWidget {
//   final List<AudiencePollModel>? poll;
//
//   AudiencePollListWidget(this.poll);
//
//   @override
//   _AudiencePollListWidgetState createState() => _AudiencePollListWidgetState();
// }
//
// class _AudiencePollListWidgetState extends State<AudiencePollListWidget> {
//   PageController audiencePollPageController = PageController();
//
//   List<double> heights = [];
//   int currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }
//
//   void init() async {
//     heights = widget.poll!.map((e) => 0.0).toList();
//     audiencePollPageController = PageController()
//       ..addListener(() {
//         if (currentPage != audiencePollPageController.page!.round()) {
//           setState(() {
//             currentPage = audiencePollPageController.page!.round();
//           });
//         }
//       });
//   }
//
//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }
//
//   @override
//   void dispose() {
//     audiencePollPageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       curve: Curves.easeInOutCubic,
//       duration: const Duration(milliseconds: 500),
//       tween: Tween<double>(begin: heights[0], end: heights[currentPage]),
//       builder: (context, value, child) {
//         return Container(
//           height: value,
//           width: context.width(),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 height: value,
//                 child: PageView(
//                   controller: audiencePollPageController,
//                   children: widget.poll!
//                       .asMap() //
//                       .map(
//                         (index, child) => MapEntry(
//                           index,
//                           OverflowBox(
//                             minHeight: 0,
//                             maxHeight: double.infinity,
//                             alignment: Alignment.topCenter,
//                             child: SizeReportingWidget(
//                               onSizeChange: (size) {
//                                 setState(() {
//                                   heights[index] = size.height;
//                                 });
//                               },
//                               child: Align(child: AudiencePollItemWidget(model: widget.poll![index])),
//                             ),
//                           ),
//                         ),
//                       )
//                       .values
//                       .toList(),
//                 ),
//               ),
//               FutureBuilder(
//                 future: 500.milliseconds.delay,
//                 builder: (_, snap) {
//                   if (snap.connectionState == ConnectionState.done) {
//                     return Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         if (audiencePollPageController.page!.ceil() <= 1 && widget.poll!.length >= 2)
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor),
//                               child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.iconColor),
//                             ),
//                           ),
//                         if (audiencePollPageController.page!.ceil() >= 1)
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor),
//                               child: Icon(Icons.arrow_back_ios, size: 14, color: context.iconColor),
//                             ),
//                           ),
//                       ],
//                     );
//                   }
//
//                   return SizedBox();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class SizeReportingWidget extends StatefulWidget {
//   final Widget? child;
//   final ValueChanged<Size>? onSizeChange;
//
//   const SizeReportingWidget({
//     Key? key,
//     @required this.child,
//     @required this.onSizeChange,
//   }) : super(key: key);
//
//   @override
//   _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
// }
//
// class _SizeReportingWidgetState extends State<SizeReportingWidget> {
//   Size? _oldSize;
//
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
//     return widget.child!;
//   }
//
//   void _notifySize() {
//     if (!this.mounted) {
//       return;
//     }
//     final size = context.size;
//     if (_oldSize != size) {
//       _oldSize = size;
//       widget.onSizeChange!(size!);
//     }
//   }
// }
