import 'dart:async';
import 'dart:io';

import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  final Room room;
  const ChatPage({required this.room, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (room.id == null) {
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "مشکل در برقراری ارتباط با سرور",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    }
    return ChatPageWithRoom(
      room: room,
    );
  }
}

class ChatPageWithRoom extends StatefulWidget {
  final Room room;
  const ChatPageWithRoom({required this.room, super.key});

  @override
  ChatController createState() => ChatController();
}

class ChatController extends State<ChatPageWithRoom> {
  Room get room => widget.room;
  late Future<void> loadTimelineFuture;
  late Client client;
  late Timeline timeline;
  late String readMarkerEventId;
  List<Event> selectedEvents = [];
   bool get selectMode => selectedEvents.isNotEmpty;

  @override
  void initState() {
    client = Provider.of<ClientProvider>(context, listen: false).client!;
    readMarkerEventId = room.fullyRead;
    loadTimelineFuture = _getTimeline(eventContextId: readMarkerEventId);
    super.initState();
  }

  void updateView() {
    if (!mounted) return;
    setState(() {});
  }

  //_getTimeLine
  Future<void> _getTimeline({
    required String eventContextId,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    await client.roomsLoading;
    await client.accountDataLoading;
    if (eventContextId != null &&
        (!eventContextId.isValidMatrixId || eventContextId.sigil != '\$')) {
      eventContextId = "";
    }
    try {
      timeline = await room
          .getTimeline(
            onUpdate: updateView,
            eventContextId: eventContextId,
          )
          .timeout(timeout);
    } catch (e, s) {
      Logs().w('Unable to load timeline on event ID $eventContextId', e, s);
      if (!mounted) return;
      timeline = await room.getTimeline(onUpdate: updateView);
      if (!mounted) return;
      if (e is TimeoutException || e is IOException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("jumpToLastReadMessage"),
            action: SnackBarAction(
              label: "jump",
              onPressed: () {}
              //  scrollToEventId(eventContextId)
              ,
            ),
          ),
        );
      }
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    return ChatView(
      controller: this,
      room: widget.room,
    );
  }
}
