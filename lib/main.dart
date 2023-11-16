import 'package:basis/data/backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/homepage.dart';
import 'pages/subpages/error.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  Backend backend = Backend(); // Initialize backend
  backend.heartBeat(); // Send heartbeat
  ErrorControl eC = await backend.checkVersions(); // Check versions

  runApp(MyApp(
    versionControl: eC,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.versionControl});
  // Root widget of the app

  final ErrorControl versionControl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BASIS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: DefaultTextStyle(
            style: GoogleFonts.exo2(),
            child: versionControl.success // Check if version check was successful
                ? const HomePage()
                : ErrorPage(versionControl: versionControl)));
  }
}
