import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/widget/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class Message extends StatelessWidget {
  final Event event;
  final Event? nextEvent;
  final Timeline timeline;
  const Message({
    required this.event,
    required this.nextEvent,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    ClientProvider clientProvider = Provider.of<ClientProvider>(context);
    clientProvider.getClient();
    Client client = clientProvider.client;
    final ownMessage = event.senderId == client.userID;

    final alignment = ownMessage ? Alignment.topRight : Alignment.topLeft;
    var color = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Theme.of(context).colorScheme.surfaceVariant;
    final textColor = ownMessage
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onBackground;
    final rowMainAxisAlignment =
        ownMessage ? MainAxisAlignment.end : MainAxisAlignment.start;

    final displayEvent = event.getDisplayEvent(timeline);
    final noBubble = {
          MessageTypes.Video,
          MessageTypes.Image,
          MessageTypes.Sticker
        }.contains(event.messageType) &&
        !event.redacted;
    final noPadding = {
      MessageTypes.File,
      MessageTypes.Audio,
    }.contains(event.messageType);

    if (ownMessage) {
      final color = displayEvent.status.isError
          ? Colors.redAccent
          : Theme.of(context).colorScheme.primary.withOpacity(.5);
    }

    final rowChildren = <Widget>[
      ownMessage
          ? SizedBox(
              width: 44,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: event.status == EventStatus.sending
                        ? const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          )
                        : event.status == EventStatus.error
                            ? const Icon(Icons.error, color: Colors.red)
                            : null,
                  ),
                ),
              ),
            )
          : FutureBuilder(
              future: event.fetchSenderUser(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? event.senderFromMemoryOrFallback;
                return Avatar(
                  mxContent: user.avatarUrl!,
                  name: user.calcDisplayname(),
                  fontSize: 22,
                );
              },
            ),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [],
      ))
    ];
    return Container();
  }
}
