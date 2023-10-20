import 'package:chat_app/pages/events/image_viewer/image_viewer_view.dart';
import 'package:chat_app/utils/event_extension.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
class ImageViewer extends StatefulWidget {
  final Event event;

  const ImageViewer(this.event, {Key? key}) : super(key: key);

  @override
  ImageViewerController createState() => ImageViewerController();
}

class ImageViewerController extends State<ImageViewer> {
  /// Forward this image to another room.
  // void forwardAction() {
  //   Matrix.of(context).shareContent = widget.event.content;
  //   VRouter.of(context).to('/rooms');
  // }

  /// Save this file with a system call.
  void saveFileAction(BuildContext context) => widget.event.saveFile(context);

  /// Save this file with a system call.
  void shareFileAction(BuildContext context) => widget.event.shareFile(context);

  static const maxScaleFactor = 1.5;

  /// Go back if user swiped it away
  void onInteractionEnds(ScaleEndDetails endDetails) {
    // if (Platform.usesTouchscreen == false) {
    //   if (endDetails.velocity.pixelsPerSecond.dy >
    //       MediaQuery.of(context).size.height * maxScaleFactor) {
    //     Navigator.of(context, rootNavigator: false).pop();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) => ImageViewerView(this);
}
