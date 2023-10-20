import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/events/message_content.dart';
import 'package:chat_app/utils/date_time_extension.dart';
import 'package:chat_app/utils/string_color.dart';
import 'package:chat_app/widget/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

class Message extends StatelessWidget {
  final Event event;
  final Event? nextEvent;
  final bool displayReadMarker;
  final void Function(Event)? onSelect;
  final void Function(Event)? onAvatarTab;
  final void Function(Event)? onInfoTab;
  final void Function(String)? scrollToEventId;
  final void Function(SwipeDirection) onSwipe;

  final bool longPressSelect;
  final bool selected;
  final Timeline timeline;

  const Message(
    this.event, {
    this.nextEvent,
    this.displayReadMarker = false,
    this.longPressSelect = false,
    this.onSelect,
    this.onInfoTab,
    this.onAvatarTab,
    this.scrollToEventId,
    this.selected = false,
    required this.onSwipe,
    required this.timeline,
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    ClientProvider clientProvider = Provider.of<ClientProvider>(context);
    clientProvider.getClient();

    Client client = clientProvider.client;
    final ownMessage = event.senderId == client.userID;
    final displayTime = event.type == EventTypes.RoomCreate ||
        nextEvent == null ||
        !event.originServerTs.sameEnvironment(nextEvent!.originServerTs);
    final sameSender = nextEvent != null &&
            [
              EventTypes.Message,
              EventTypes.Sticker,
              EventTypes.Encrypted,
            ].contains(nextEvent!.type)
        ? nextEvent!.senderId == event.senderId && !displayTime
        : false;
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
    final borderRadius = BorderRadius.only(
      topLeft:
          !ownMessage ? const Radius.circular(4) : const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(16),
      bottomRight:
          ownMessage ? const Radius.circular(4) : const Radius.circular(16),
    );

    if (ownMessage) {
      final color = displayEvent.status.isError
          ? Colors.redAccent
          : Theme.of(context).colorScheme.primary.withOpacity(.5);
    }

    final rowChildren = <Widget>[
      if (ownMessage)
        SizedBox(
          width: Avatar.defaultSize,
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
        ),
      /* :FutureBuilder<User?>(
              future: event.fetchSenderUser(),
              builder: (context, snapshot) {
                final user = snapshot.data ?? event.senderFromMemoryOrFallback;
                return Avatar(
                  mxContent: user.avatarUrl,
                  name: user.calcDisplayname(),
                  onTap: () => onAvatarTab!(event),
                );
              },
            ),*/

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!sameSender)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                child: ownMessage || event.room.isDirectChat
                    ? const SizedBox(height: 12)
                    : FutureBuilder<User?>(
                        future: event.fetchSenderUser(),
                        builder: (context, snapshot) {
                          final displayname =
                              snapshot.data?.calcDisplayname() ??
                                  event.senderFromMemoryOrFallback
                                      .calcDisplayname();
                          return Text(
                            displayname,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: (Theme.of(context).brightness ==
                                      Brightness.light
                                  ? displayname.color
                                  : displayname.lightColorText),
                            ),
                          );
                        },
                      ),
              ),
            Container(
              alignment: alignment,
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: noBubble
                    ? Colors.transparent
                    : event.messageType.contains("q.")
                        ? Colors.transparent
                        : color,
                elevation: event.type == EventTypes.Sticker
                    ? 0
                    : event.messageType.contains("q.")
                        ? 0
                        : 4,
                shadowColor: event.messageType.contains("q.")
                    ? Colors.transparent
                    : Colors.black.withAlpha(64),
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // onHover: (b) => useMouse = true,
                  onTap: () {},
                  //  !useMouse && longPressSelect
                  //     ? () {}
                  //     : () => onSelect!(event),
                  onLongPress: !longPressSelect ? null : () => onSelect!(event),
                  borderRadius: borderRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: noBubble || noPadding
                        ? EdgeInsets.zero
                        : EdgeInsets.all(16),
                    constraints: const BoxConstraints(
                      maxWidth: 360,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (!sameSender)
                              FutureBuilder<User?>(
                                future: event.fetchSenderUser(),
                                builder: (context, snapshot) {
                                  final user = snapshot.data ??
                                      event.senderFromMemoryOrFallback;
                                  return Avatar(
                                    size: 30,
                                    mxContent: user.avatarUrl,
                                    name: user.calcDisplayname(),
                                    onTap: () => onAvatarTab!(event),
                                  );
                                },
                              ),
                            if (!sameSender)
                              SizedBox(
                                height: 5,
                              ),
                            if (event.relationshipType ==
                                RelationshipTypes.reply)
                              FutureBuilder<Event?>(
                                future: event.getReplyEvent(timeline),
                                builder: (BuildContext context, snapshot) {
                                  final replyEvent = snapshot.hasData
                                      ? snapshot.data!
                                      : Event(
                                          eventId: event.relationshipEventId!,
                                          content: {
                                            'msgtype': 'm.text',
                                            'body': '...'
                                          },
                                          senderId: event.senderId,
                                          type: 'm.room.message',
                                          room: event.room,
                                          status: EventStatus.sent,
                                          originServerTs: DateTime.now(),
                                        );
                                  return InkWell(
                                    onTap: () {
                                      // if (scrollToEventId != null) {
                                      //   scrollToEventId!(replyEvent.eventId);
                                      // }
                                    },
                                    child: AbsorbPointer(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        // child: ReplyContent(
                                        //   replyEvent,
                                        //   ownMessage: ownMessage,
                                        //   timeline: timeline,
                                        // ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            MessageContent(
                              displayEvent,
                              textColor: textColor,
                              // onInfoTab: onInfoTab,
                            ),
                            if (event.hasAggregatedEvents(
                              timeline,
                              RelationshipTypes.edit,
                            ))
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 4.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      color: textColor.withAlpha(164),
                                      size: 14,
                                    ),
                                    Text(""
                                        // ' - ${displayEvent.originServerTs.localizedTimeShort(context)}',
                                        // style: TextStyle(
                                        //   color: textColor.withAlpha(164),
                                        //   fontSize: 12,
                                        // ),
                                        ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: rowMainAxisAlignment,
      children: rowChildren,
    );
    Widget container;
    if (event.hasAggregatedEvents(timeline, RelationshipTypes.reaction) ||
        displayTime ||
        selected ||
        displayReadMarker) {
      container = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            ownMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          if (displayTime || selected)
            Padding(
              padding: displayTime
                  ? EdgeInsets.symmetric(
                      vertical: 8.0,
                    )
                  : EdgeInsets.zero,
              child: Center(
                child: Material(
                  color: displayTime
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.33),
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(""
                        // event.originServerTs.localizedTime(context),
                        // style: TextStyle(fontSize: 14 * AppConfig.fontSizeFactor),
                        ),
                  ),
                ),
              ),
            ),
          row,
          // if (event.hasAggregatedEvents(timeline, RelationshipTypes.reaction))
          //   Padding(
          //     padding: EdgeInsets.only(
          //       top: 4.0,
          //       left: (ownMessage ? 0 : Avatar.defaultSize) + 12.0,
          //       right: 12.0,
          //     ),
          //     child: MessageReactions(event, timeline),
          // ),
          if (displayReadMarker)
            Row(
              children: [
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.primary),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Text(""
                      // L10n.of(context)!.readUpToHere,
                      // style:
                      //     TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                ),
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
        ],
      );
    } else {
      container = row;
    }

    return Swipeable(
      key: ValueKey(event.eventId),
      background: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Icon(Icons.reply_outlined),
        ),
      ),
      direction: SwipeDirection.endToStart,
      onSwipe: onSwipe,
      child: Center(
        child: Container(
          color: selected
              ? Theme.of(context).primaryColor.withAlpha(100)
              : Theme.of(context).primaryColor.withAlpha(0),
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: container,
          ),
        ),
      ),
    );
  }
}
