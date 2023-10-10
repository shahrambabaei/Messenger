import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/events/messege.dart';
import 'package:flutter/material.dart';

class ChatEventList extends StatelessWidget {
  final ChatController controller;
  const ChatEventList({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thisEventsKeyMap = <String, int>{};
    for (var i = 0; i < controller.timeline!.events.length; i++) {
      thisEventsKeyMap[controller.timeline!.events[i].eventId] = i;
    }
    return ListView.custom(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 4,
        left: 10,
        right: 10,
      ),
      reverse: true,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, int i) {
          // Footer to display typing indicator and read receipts:
          if (i == 0) {
            if (controller.timeline!.isRequestingFuture) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestFuture) {
              return Builder(
                builder: (context) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => controller.requestFuture());
                  return Center(
                      child: IconButton(
                          onPressed: controller.requestFuture,
                          icon: Icon(Icons.refresh_outlined)));
                },
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SeenByRow(controller),
                // TypingIndicators(controller),
              ],
            );
          }
          // Request history button or progress indicator:
          if (i == controller.timeline!.events.length + 1) {
            if (controller.timeline!.isRequestingHistory) {
              return const Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            }
            if (controller.timeline!.canRequestHistory) {
              return Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => controller.requestHistory(),
                  );
                  return Center(
                    child: IconButton(
                      onPressed: controller.requestHistory,
                      icon: const Icon(Icons.refresh_outlined),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }
          final event = controller.timeline!.events[i - 1];
          return Message(
              event: event,
              nextEvent: i < controller.timeline!.events.length
                  ? controller.timeline!.events[i]
                  : null,
              timeline: controller.timeline!);
        },
        childCount: controller.timeline!.events.length + 2,
        findChildIndexCallback: (key) =>
            controller.findChildIndexCallback(key, thisEventsKeyMap),
      ),
    );
  }
}
