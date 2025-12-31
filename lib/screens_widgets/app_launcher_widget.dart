library;

//
// Flutter packages
//
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_searcher/models/desktop_entry.dart';
import 'package:launch_searcher/models/global_data.dart';
import 'package:launch_searcher/utils/desktop_app_finder.dart';

class AppLauncherWidget extends StatefulWidget {
  const AppLauncherWidget({super.key, required this.searchTerm, this.selectedIndex = -1});

  //
  // input of the search term
  //
  final String searchTerm;
  //
  // selected index
  //
  final int selectedIndex;
  @override
  State<AppLauncherWidget> createState() => _AppLauncherWidgetState();
}

class _AppLauncherWidgetState extends State<AppLauncherWidget> {
  late Future<List<DesktopEntry>> _appsFuture;
  final DesktopAppFinder _appFinder = DesktopAppFinder();

  @override
  void initState() {
    super.initState();
    _appsFuture = _appFinder.findAndParseApps();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DesktopEntry>>(
      future: _appsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ein Fehler ist aufgetreten: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Anwendungen gefunden.'));
        }

        globalData.desktopEntries = snapshot.data!;
        globalData.desktopEntries = DesktopEntry.filterDesktopEntries(globalData.desktopEntries, widget.searchTerm);
        return ListView.builder(
          itemCount: globalData.desktopEntries.length,
          itemBuilder: (context, index) {
            //
            // set the selected desktop entry
            //
            globalData.selectedDesktopEntry = globalData.desktopEntries[index];
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
              leading: globalData.desktopEntries[index].iconWidget,
              title: Text(globalData.desktopEntries[index].name, style: TextStyle(color: GlobalData().walColors!.special.foreground)),
              onTap: () async {
                //
                // start the app
                //
                await globalData.desktopEntries[index].launch();

                //
                // close the LaunchSearcher
                //
                exit(0);
              },
            );
          },
        );
      },
    );
  }
}
