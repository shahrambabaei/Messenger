import 'dart:io';

import 'package:chat_app/widget/mxc_image.dart';
import 'package:flutter/material.dart';
import 'image_viewer.dart';

class ImageViewerView extends StatelessWidget {
  final ImageViewerController controller;

  const ImageViewerView(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
          color: Colors.white,
          tooltip: "close",
        ),
        backgroundColor: const Color(0x44000000),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.reply_outlined),
          //   onPressed: controller.forwardAction,
          //   color: Colors.white,
          //   tooltip:"share",
          // ),
          if (!Platform.isIOS)
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => controller.saveFileAction(context),
              color: Colors.white,
              tooltip: "downloadFile",
            ),
          // if (PlatformInfos.isMobile)
          //   // Use builder context to correctly position the share dialog on iPad
          //   Builder(
          //     builder: (context) => IconButton(
          //       onPressed: () => controller.shareFileAction(context),
          //       tooltip: "share",
          //       color: Colors.white,
          //       icon: Icon(Icons.adaptive.share_outlined),
          //     ),
          //   )
        ],
      ),
      body: InteractiveViewer(
        minScale: 1.0,
        maxScale: 10.0,
        onInteractionEnd: controller.onInteractionEnds,
        child: Center(
          child: Hero(
            tag: controller.widget.event.eventId,
            child: MxcImage(
              event: controller.widget.event,
              fit: BoxFit.contain,
              isThumbnail: false,
              animated: true,
            ),
          ),
        ),
      ),
    );
  }
}
