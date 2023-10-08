import 'dart:async';

import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/roomlist_page.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late ClientProvider clientProvider;
  late Client client;

  @override
  void initState() {
    clientProvider = Provider.of<ClientProvider>(context, listen: false);
    clientProvider.getClient();
    client = clientProvider.client;
    Timer(const Duration(seconds: 5), () {
      client.isLogged()
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const RoomListPage(),
            ))
          : Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) =>const Loginpage()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
          ),
          SizedBox(
            height: 15,
          ),
          Text("Messenger")
        ],
      )),
    );
  }
}
