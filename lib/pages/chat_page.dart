import 'dart:async';
import 'dart:io';

import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/chat_view.dart';
import 'package:chat_app/pages/events/send_file_dialog.dart';
import 'package:chat_app/utils/matrix_file_extension.dart';
import 'package:file_picker/file_picker.dart';
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
  TextEditingController sendController = TextEditingController();
  Room get room => widget.room;
  late Future<void> loadTimelineFuture;
  late Client client;
  Event? replyEvent;
  Event? editEvent;
  Timeline? timeline;
  late String readMarkerEventId;
  List<Event> selectedEvents = [];
  bool get selectMode => selectedEvents.isNotEmpty;
  FocusNode inputFocus = FocusNode();
  String get roomId => widget.room.id;
  bool isRequestingHistory = false;
  bool isRequestingFuture = false;
  final int _loadHistoryCount = 100;
  String pendingText = '';
  String inputText = '';

  void onAddPopupMenuButtonSelected(String choice) {
    if (choice == 'file') {
      sendFileAction();
    }
    if (choice == 'image') {
      sendImageAction();
    }
    if (choice == 'camera') {
      // openCameraAction();
    }
    if (choice == 'camera-video') {
      // openVideoCameraAction();
    }
    if (choice == 'sticker') {
      // sendStickerAction();
    }
    if (choice == 'location') {
      // sendLocationAction();
    }
  }

  void sendFileAction() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (c) => SendFileDialog(
        files: result.files
            .map(
              (xfile) => MatrixFile(
                bytes: xfile.bytes!,
                name: xfile.name,
              ).detectFileType,
            )
            .toList(),
        room: room,
      ),
    );
  }

  void sendImageAction() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (c) => SendFileDialog(
        files: result.files
            .map(
              (xfile) => MatrixFile(
                bytes: xfile.bytes!,
                name: xfile.name,
              ).detectFileType,
            )
            .toList(),
        room: room,
      ),
    );
  }

  @override
  void initState() {
    client = Provider.of<ClientProvider>(context, listen: false).client;
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

  Future<void> send() async {
    room.sendTextEvent(
      sendController.text,
      inReplyTo: replyEvent,
      editEventId: editEvent?.eventId,
      // parseCommands: parseCommands,
    );

    sendController.value = TextEditingValue(
      text: pendingText,
      selection: const TextSelection.collapsed(offset: 0),
    );

    void sendFileAction() async {
      // final result = await FilePicker.platform.pickFiles(
      //   allowMultiple: true,
      //   withData: true,
      // );
      // if (result == null || result.files.isEmpty) return;
      // await showDialog(
      //   context: context,
      //   useRootNavigator: false,
      //   builder: (c) => SendFileDialog(
      //     files: result.files
      //         .map(
      //           (xfile) => MatrixFile(
      //             bytes: xfile.bytes,
      //             name: xfile.name,
      //           ).detectFileType,
      //         )
      //         .toList(),
      //     room: room,
      //   ),
      // );
    }

    void sendImageAction() async {
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.image,
      //   withData: true,
      //   allowMultiple: true,
      // );
      // if (result == null || result.files.isEmpty) return;

      // await showDialog(
      //   context: context,
      //   useRootNavigator: false,
      //   builder: (c) => SendFileDialog(
      //     files: result.files
      //         .map(
      //           (xfile) => MatrixFile(
      //             bytes: xfile.bytes,
      //             name: xfile.name,
      //           ).detectFileType,
      //         )
      //         .toList(),
      //     room: room,
      //   ),
      // );
    }

    setState(() {
      inputText = pendingText;
      replyEvent = null;
      editEvent = null;
      pendingText = '';
    });
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
    if (!timeline!.canRequestHistory) return;
    Logs().v('Requesting history...');
    try {
      await timeline!.requestHistory(historyCount: _loadHistoryCount);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطایی رخ داده است"
              // (err).toLocalizedString(context),F
              ),
        ),
      );
      rethrow;
    }
  }

  int? findChildIndexCallback(Key key, Map<String, int> thisEventsKeyMap) {
    // this method is called very often. As such, it has to be optimized for speed.
    if (key is! ValueKey) {
      return null;
    }
    final eventId = key;
    if (eventId is! String) {
      return null;
    }
    // first fetch the last index the event was at
    final index = thisEventsKeyMap[eventId];
    if (index == null) {
      return null;
    }
    // we need to +1 as 0 is the typing thing at the bottom
    return index + 1;
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

    replyAction({Event? replyTo}) {
      setState(() {
        replyEvent = replyTo ?? selectedEvents.first;
        selectedEvents.clear();
      });
      inputFocus.requestFocus();
    }
  }

  replyAction({required Event replyTo}) {}

  //_getTimeLine
  Future<void> _getTimeline({
    String? eventContextId,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    await client.roomsLoading;
    await client.accountDataLoading;
    if (eventContextId != null &&
        (!eventContextId.isValidMatrixId || eventContextId.sigil != '\$')) {
      eventContextId = null;
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
  // Future<void> _getTimeline({
  //   String? eventContextId,
  //   Duration timeout = const Duration(seconds: 7),
  // }) async {
  //   await client.roomsLoading;
  //   await client.accountDataLoading;
  //   if (eventContextId != null &&
  //       (!eventContextId.isValidMatrixId || eventContextId.sigil != '\$')) {
  //     eventContextId = null;
  //   }
  //   try {
  //     timeline = await room
  //         .getTimeline(
  //           onUpdate: updateView,
  //           eventContextId: eventContextId,
  //         )
  //         .timeout(timeout);
  //     print("TimeLine Is:$timeline");
  //   } catch (e, s) {
  //     Logs().w('Unable to load timeline on event ID $eventContextId', e, s);
  //     if (!mounted) return;
  //     timeline = await room.getTimeline(onUpdate: updateView);
  //     if (!mounted) return;
  //     if (e is TimeoutException || e is IOException) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text("jumpToLastReadMessage"),
  //           action: SnackBarAction(
  //             label: "jump",
  //             onPressed: () {}
  //             //  scrollToEventId(eventContextId)
  //             ,
  //           ),
  //         ),
  //       );
  //     }
  //   }

  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    return ChatView(
      controller: this,
      room: widget.room,
    );
  }
}
