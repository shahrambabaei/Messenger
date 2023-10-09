import 'dart:async';
import 'dart:io';

import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

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
  late Event replyEvent;
  late Event editEvent;
  late Timeline timeline;
  late String readMarkerEventId;
  List<Event> selectedEvents = [];
  bool get selectMode => selectedEvents.isNotEmpty;
  FocusNode inputFocus = FocusNode();
  String get roomId => widget.room.id;
   bool isRequestingHistory = false;
  bool isRequestingFuture = false;
   final int _loadHistoryCount = 100;

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

  void copyEventsAction() {
    Clipboard.setData(ClipboardData(text: _getSelectedEventString()))
        .then((value) => Fluttertoast.showToast(
                  msg: "متن کپی شد",
                )

            // FlutterToastr.show(
            //      ,
            //       context,
            //       duration: FlutterToastr.lengthLong,
            //       position: FlutterToastr.top,
            //     )
            );
    setState(() {
      selectedEvents.clear();
    });
  }

  _getSelectedEventString() {
    for (final event in selectedEvents) {
      return event.plaintextBody;
    }
  }

  bool get canRedactSelectedEvents {
    // if (isArchived) return false;
    // final clients = Matrix.of(context).currentBundle;
    for (final event in selectedEvents) {
      if (event.canRedact == false && !(event.senderId == client.userID)) {
        return false;
      }
    }
    return true;
  }


   void requestFuture() async {
    final timeline = this.timeline;
    if (timeline == null) return;
    if (!timeline.canRequestFuture) return;
    Logs().v('Requesting future...');
    try {
      final mostRecentEventId = timeline.events.first.eventId;
      await timeline.requestFuture(historyCount: _loadHistoryCount);
      // setReadMarker(eventId: mostRecentEventId);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "حطایی رخ داده است"
            // (err).toLocalizedStrin(context)
            ,
          ),
        ),
      );
      rethrow;
    }
  }


   void requestHistory() async {
    if (!timeline.canRequestHistory) return;
    Logs().v('Requesting history...');
    try {
      await timeline.requestHistory(historyCount: _loadHistoryCount);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
           "خطایی رخ داده است"
            // (err).toLocalizedString(context),
          ),
        ),
      );
      rethrow;
    }
  }

  void redactEventsAction() async {
    final confirmed = await showOkCancelAlertDialog(
            useRootNavigator: false,
            context: context,
            title: 'آیا از حذف این پیام اطمینان دارید؟',
            okLabel: 'بله',
            cancelLabel: 'خیر',
            style: AdaptiveStyle.adaptive) ==
        OkCancelResult.ok;
    if (!confirmed) return;
    for (final event in selectedEvents) {
      await showFutureLoadingDialog(
        context: context,
        future: () async {
          if (event.status.isSent) {
            if (event.canRedact) {
              await event.redactEvent();
            } else {
              if (client == null) {
                return;
              }
              final room = client.getRoomById(roomId);
              await Event.fromJson(event.toJson(), room!).redactEvent();
              // final x = selectedEvents.first.senderId == client.userID;

              // if (x == null) {
              //   return;
              // }
              // final room = client.getRoomById(roomId)!;
              // await Event.fromJson(event.toJson(), room).redactEvent();
              // //
              //   final client = currentRoomBundle.firstWhere(
              //   (cl) => selectedEvents.first.senderId == cl!.userID,
              //   orElse: () => null,
              // );
              // if (client == null) {
              //   return;
              // }
              // final room = client.getRoomById(roomId);
              // await Event.fromJson(event.toJson(), room).redactEvent();
            }
          } else {
            await event.remove();
          }
        },
      );
    }
    setState(() {
      selectedEvents.clear();
    });

    void replyAction({Event? replyTo}) {
      setState(() {
        replyEvent = replyTo ?? selectedEvents.first;
        selectedEvents.clear();
      });
      inputFocus.requestFocus();
    }
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
