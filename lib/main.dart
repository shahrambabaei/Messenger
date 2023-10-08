import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/roomlist_page.dart';
import 'package:chat_app/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final client = Client(
  //   'Matrix Example Chat',
  //   databaseBuilder: (_) async {
  //     final dir = await getApplicationSupportDirectory();
  //     final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
  //     await db.open();
  //     return db;
  //   },
  // );
  // await client.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ClientProvider>(
            create: (context) => ClientProvider(),
          ),
        ],
        child: MaterialApp(
          title: 'Chat App',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale:const Locale("fa"),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home:SplashPage(),
        ));
  }
}
