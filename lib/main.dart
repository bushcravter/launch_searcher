library;

//
// Flutter packages
//
import 'package:flutter/material.dart';
import 'package:launch_searcher/models/global_data.dart';
import 'package:launch_searcher/screens_widgets/home_screen.dart';
//
// pub.dev packages
//
import 'package:window_manager/window_manager.dart';
//
// internal packages
//

void main() async {
  //
  // first initializing widget system
  //
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  //
  // load the pywal colors
  //
  await GlobalData().loadWalTheme();
  //
  // set the window options
  //
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: GlobalData().walColors!.special.background,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const LaunchSearcherApp());
}

class LaunchSearcherApp extends StatelessWidget {
  const LaunchSearcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Launch Searcher App',
      home: HomePage(),
    );
  }
}
