import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

class ClientProvider extends ChangeNotifier {
  late Client client;
  Future<Client> getClient() async {
    client = Client(
      'Matrix Chat',
      databaseBuilder: (_) async {
        final dir = await getApplicationSupportDirectory();
        final db = HiveCollectionsDatabase('matrix chat', dir.path);
        await db.open();
        return db;
      },
    );
    await client.init();
    return client;
  }
}
