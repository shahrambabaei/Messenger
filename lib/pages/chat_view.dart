import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/events/chat_event_list.dart';
import 'package:chat_app/utils/theme/chatcolor_theme.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ChatView extends StatelessWidget {
  final ChatController controller;
  final Room room;
  const ChatView({required this.controller, required this.room, Key? key})
      : super(key: key);
 List<Widget> _appBarActions(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final client = clientProvider.client;
    if (controller.selectMode) {
      return [
        // if (controller.canEditSelectedEvents(client))
        // IconButton(
        //     icon: const Icon(Icons.edit_outlined, color: Colors.red),
        //     tooltip: "edit",
        //     onPressed: () {}
        //     //  widget.controller.editSelectedEventAction,
        //     ),

        if (controller.selectedEvents.length == 1 &&
            controller.selectedEvents.first.messageType == "m.text")
          IconButton(
            icon: Icon(
              Icons.copy_outlined,
              color:
               context.chatColorPick(
                  dark: ChatColorPalette.white, light: ChatColorPalette.black),
            ),
            tooltip: "copy",
            onPressed: controller.copyEventsAction,
          ),
        if (controller.canRedactSelectedEvents)
          IconButton(
            icon: Icon(
              Icons.delete_outlined,
              color: context.chatColorPick(
                  dark: ChatColorPalette.white, light: ChatColorPalette.black),
            ),
            tooltip: "redactMessage",
            onPressed: controller.redactEventsAction,
          ),
      ];
    } else {
      return [
        Container(
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.center,
          child: Text(
            room.displayname,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        )
      ];
    }
  }

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
                        title: controller.selectMode
                            ? Text(
                                controller.selectedEvents.length.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 22),
                              )
                            : const Text(""),
                        leading: controller.selectMode
                            ? IconButton(
                                onPressed: () {}, icon: Icon(Icons.close))
                            : IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back)),
                                actions: _appBarActions(context),
                                
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








