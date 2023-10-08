import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/events/chat_event_list.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

class ChatView extends StatelessWidget {
  final ChatController controller;
  final Room room;
  const ChatView({required this.controller, required this.room, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (controller.room.membership == Membership.invite) {
      showFutureLoadingDialog(
        context: context,
        future: () => controller.room.join(),
      );
    }
    return SafeArea(
        child: StreamBuilder(
            stream: controller.room.onUpdate.stream,
            builder: (context, snapshot) => FutureBuilder(
                  future: controller.loadTimelineFuture,
                  builder: (context, snapshot) {
                    return Scaffold(
                      appBar: AppBar(
                        elevation: 3,
                        shadowColor: Colors.black,
                        backgroundColor: Colors.white,
                        title: Text("ChatView"),
                        leading: controller.selectMode
                            ? IconButton(
                                onPressed: () {}, icon: Icon(Icons.close))
                            : IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back)),
                      ),
                      body: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              colors: [
                                colorScheme.primaryContainer.withAlpha(64),
                                colorScheme.primaryContainer.withAlpha(64),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                            child: Column(
                          children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () {},
                              child: Builder(
                                builder: (context) {
                                  if (controller.timeline == null) {
                                    return const Center(
                                      child: CircularProgressIndicator.adaptive(
                                          strokeWidth: 2),
                                    );
                                  }
                                  return ChatEventList(controller: controller);
                                },
                              ),
                            )),
                            Container(
                              height: 56,
                              margin: const EdgeInsets.only(
                                bottom: 10,
                                left: 10,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12)),
                              ),
                            )
                          ],
                        ))
                      ]),
                    );
                  },
                )));
  }
}








// class ChatView extends StatelessWidget {
  
//   final ChatController chatController;
//   final Room room;
//   const ChatView({required this.chatController,required this.room});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }