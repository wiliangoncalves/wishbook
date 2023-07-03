import 'package:app/screens/login.dart' show LoginState;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/storage/secure_storage.dart' show SecureStorage;
import 'package:app/src/bottomnavigatorbar.dart' show BottomNavigatorBarState;

var pass = true;

Future<void> main() async {
  await dotenv.load();

  var checkToken = await SecureStorage.readData('token');

  checkToken == null ? pass = false : pass = true;

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'WishBook',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],
      home: pass == false ? const LoginState() : const BottomNavigatorBarState(),
    );
  }
}
