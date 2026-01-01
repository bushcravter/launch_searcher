library;
// 
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
// pub.dev packages
//
//
// internal packages
//
import 'package:launch_searcher/models/cliphist_entry.dart';
import 'package:launch_searcher/models/contact_telephone_entry.dart';
import 'package:launch_searcher/models/global_data.dart';

class CliphistLauncherWidget extends StatefulWidget {
  const CliphistLauncherWidget({super.key, required this.searchTerm, this.selectedIndex = -1});

  //
  // input of the search term
  //
  final String searchTerm;
  //
  // selected index
  //
  final int selectedIndex;
  @override
  State<CliphistLauncherWidget> createState() => _CliphistLauncherWidgetState();
}

class _CliphistLauncherWidgetState extends State<CliphistLauncherWidget> {
  late Future<List<CliphistEntry>> _cliphistFuture;

  @override
  void initState() {
    super.initState();
    _cliphistFuture = CliphistEntry.readHistory();
  }

  //
  // Diese Methode wird bei jedem Tastendruck aufgerufen
  //
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      //
      // close LaunchSearcher if ESC is pressed
      //
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        exit(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CliphistEntry>>(
      future: _cliphistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ein Fehler ist aufgetreten: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Anwendungen gefunden.'));
        }
        globalData.cliphistEntries = snapshot.data!;
        globalData.cliphistEntries = CliphistEntry.filterEntries(globalData.cliphistEntries, widget.searchTerm);
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: ListView.builder(
           itemCount: globalData.cliphistEntries.length,
            itemBuilder: (context, index) {
              //
              // set the selected contact entry
              //
              globalData.selectedCliphistEntry= globalData.cliphistEntries[index];
              //
              // return the list tiles
              //
              return ListTile(
                selected: index == widget.selectedIndex,
                focusColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                selectedTileColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                selectedColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                hoverColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                tileColor: GlobalData().walColors!.special.background,
                splashColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                title: Text(
                  globalData.cliphistEntries[index].content,
                  style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  //
                  // start the app
                  //
                  await globalData.cliphistEntries[index].launch();
          
                  //
                  // close the LaunchSearcher
                  //
                  exit(0);
                },
              );
            },
          ),
        );
      },
    );
  }
}
