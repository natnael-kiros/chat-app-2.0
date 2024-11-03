import 'package:chat_app/model/file_model.dart';
import 'package:chat_app/providers/audio_provider.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:chat_app/providers/file_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FileCustomAdapter());

  await Hive.openBox<FileCustom>('fileBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => AudioRecorderProvider())
      ],
      child: MaterialApp(
        theme: ThemeData(
            appBarTheme:
                AppBarTheme(iconTheme: IconThemeData(color: Colors.white))),
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
