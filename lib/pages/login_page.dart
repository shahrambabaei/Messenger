import 'package:chat_app/config/clientprovider.dart';
import 'package:chat_app/pages/roomlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  late ClientProvider clientProvider;
  late Client client;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    clientProvider = Provider.of<ClientProvider>(context, listen: false);
    clientProvider.getClient();
    client = clientProvider.client;
    super.initState();
  }

  void _login() async {
    try {
      await client.checkHomeserver(Uri.http("31.7.75.201:8008", ''));
      await client.login(
        LoginType.mLoginPassword,
        password: _passwordController.text,
        identifier:
            AuthenticationUserIdentifier(user: _usernameController.text),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoomListPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.userName,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _login,
                      child: Text(AppLocalizations.of(context)!.login)),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
