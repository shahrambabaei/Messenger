import 'package:chat_app/pages/events/image_bubble.dart';
import 'package:chat_app/pages/events/message_download_content.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class MessageContent extends StatelessWidget {
  final Event event;
  final Color? textColor;
  final bool? onMassage;
  const MessageContent(
    this.event, {
    this.onMassage,
    Key? key,
    this.textColor,
  }) : super(key: key);

  void _verifyOrRequestKey(BuildContext context) async {}

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    final fontSize = 16;
    final buttonTextColor = Colors.red;
    // event.senderId == Provider.of<ClientProvider>(context, listen: false).userID
    //     ? textColor
    //     : null;

    String userSentUnknownEvent(Object username, Object type) {
      return '$username sent a $type event';
    }

    switch (event.type) {
      case EventTypes.Message:
      case EventTypes.Encrypted:
      case EventTypes.Sticker:
        Widget widget;
        switch (event.messageType) {
          case MessageTypes.Image:
            return widget = ImageBubble(
              event,
              width: 400,
              height: 300,
              fit: BoxFit.cover,
            );
          // case MessageTypes.Sticker:
          //   if (event.redacted) continue textmessage;
          //   return widget = Sticker(event);
          // case CuteEventContent.eventType:
          //   return CuteContent(event);
          // case MessageTypes.Audio:
          // if (PlatformInfos.isMobile ||
          //         PlatformInfos.isMacOS ||
          //         PlatformInfos.isWeb
          //     // Disabled until https://github.com/bleonard252/just_audio_mpv/issues/3
          //     // is fixed
          //     //   || PlatformInfos.isLinux
          //     ) {
          //   return AudioPlayerWidget(
          //     event,
          //     color: textColor,
          //   );
          // }
          // return MessageDownloadContent(event, textColor);

          // case MessageTypes.Video:
          //   if (Platform.isAndroid || Platform.isIOS || kIsWeb) {
          //     return EventVideoPlayer(event);
          //   }
          // return MessageDownloadContent(event, textColor);

          case MessageTypes.File:
            return widget = MessageDownloadContent(event, textColor!);

          case MessageTypes.Text:
          case MessageTypes.Notice:
          case MessageTypes.Emote:
            // if (AppConfig.renderHtml &&
            //     !event.redacted &&
            //     event.isRichMessage) {
            //   var html = event.formattedText;
            //   if (event.messageType == MessageTypes.Emote) {
            //     html = '* $html';
            //   }
            //   return HtmlMessage(
            //     html: html,
            //     textColor: textColor,
            //     room: event.room,
            //   );
            // }
            // else we fall through to the normal message rendering
            continue textmessage;
          case MessageTypes.BadEncrypted:
          case EventTypes.Encrypted:
            return _ButtonContent(
              textColor: buttonTextColor,
              onPressed: () => _verifyOrRequestKey(context),
              icon: const Icon(Icons.lock_outline),
              label: 'رمزگذاری شده',
            );
          // case MessageTypes.Location:
          //   final geoUri =
          //       Uri.tryParse(event.content.tryGet<String>('geo_uri'));
          //   if (geoUri != null && geoUri.scheme == 'geo') {
          //     final latlong = geoUri.path
          //         .split(';')
          //         .first
          //         .split(',')
          //         .map((s) => double.tryParse(s))
          //         .toList();
          //     if (latlong.length == 2 &&
          //         latlong.first != null &&
          //         latlong.last != null) {
          //       return Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const SizedBox(height: 6),
          //           OutlinedButton.icon(
          //             icon: Icon(Icons.location_on_outlined, color: textColor),
          //             onPressed: () {},
          //             // UrlLauncher(context, geoUri.toString()).launchUrl,
          //             label: Text(
          //               ""
          //               // L10n.of(context)!.openInMaps
          //               ,
          //               style: TextStyle(color: textColor),
          //             ),
          //           ),
          //         ],
          //       );
          //     }
          //   }
          //   continue textmessage;
          case MessageTypes.None:
          textmessage:
          default:
            if (event.redacted) {
              return FutureBuilder<User?>(
                future: event.redactedBecause!.fetchSenderUser(),
                builder: (context, snapshot) {
                  return _ButtonContent(
                    label: "پیام حذف شده است",
                    icon: Icon(
                      Icons.delete_outlined,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    textColor: textColor!,
                    onPressed: () {},
                  );
                },
              );
            }
            final bigEmotes = event.onlyEmotes &&
                event.numberEmotes > 0 &&
                event.numberEmotes <= 10;
            return Text(event.plaintextBody,
                // textAlign: onMassage ? TextAlign.right : TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 20));
          // FutureBuilder<String>(
          //   future: event.
          //   calcLocalizedBody(
          //     MatrixLocals(L10n.of(context)!),
          //     hideReply: true,
          //   ),
          //   builder: (context, snapshot) {
          //     return Linkify(
          //       text: snapshot.data ??"",
          //           // event.calcLocalizedBodyFallback(
          //           //   MatrixLocals(L10n.of(context)!),
          //           //   hideReply: true,
          //           // ),
          //       style: TextStyle(
          //         color: textColor,
          //         fontSize: 16,
          //         decoration:
          //             event.redacted ? TextDecoration.lineThrough : null,
          //       ),
          //       options: const LinkifyOptions(humanize: false),
          //       linkStyle: TextStyle(
          //         color: textColor.withAlpha(150),
          //         fontSize:16,
          //         decoration: TextDecoration.underline,
          //         decorationColor: textColor.withAlpha(150),
          //       ),
          //       // onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
          //     );
          //   },
          // );
        }
        break;
      case EventTypes.CallInvite:
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return _ButtonContent(
              label: event.senderFromMemoryOrFallback.calcDisplayname(),
              icon: const Icon(Icons.phone_outlined),
              textColor: buttonTextColor,
              onPressed: () {},
            );
          },
        );
      default:
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return _ButtonContent(
              label: userSentUnknownEvent(
                snapshot.data?.calcDisplayname() ??
                    event.senderFromMemoryOrFallback.calcDisplayname(),
                event.type,
              ),
              icon: Icon(
                Icons.info_outlined,
              ),
              textColor: buttonTextColor,
              onPressed: () {},
            );
          },
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final void Function()? onPressed;
  final String? label;
  final Icon? icon;
  final Color? textColor;

  const _ButtonContent({
    this.label,
    this.icon,
    this.textColor,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon!,
      label: Text(
        label!,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      style: OutlinedButton.styleFrom(
        splashFactory: NoSplash.splashFactory,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.5),
      ),
    );
  }
}
