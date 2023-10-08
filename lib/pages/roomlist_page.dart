import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  late ClientProvider clientProvider;
  late Client client;
  @override
  void initState() {
    clientProvider = Provider.of<ClientProvider>(context, listen: false);
    clientProvider.getClient();
    client = clientProvider.client;
    super.initState();
  }
  


    void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(room: room),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.rooms),
        ),
        body: StreamBuilder(
            stream: client.onSync.stream,
            builder: (context, snapshot) {
              return ListView.builder(
                  itemCount: client.rooms.length,
                  itemBuilder: (c, i) => ListTile(
                        leading: CircleAvatar(
                            foregroundImage: client.rooms[i].avatar == null
                                ? null
                                : NetworkImage(client.rooms[i].avatar!
                                    .getThumbnail(
                                      client,
                                      width: 56,
                                      height: 56,
                                    )
                                    .toString())),
                        title: Text(
                          client.rooms[i].displayname,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontSize: 18),
                        ),
                        onTap: () => _join(client.rooms[i]),
                      ));
            }));
  }
}
