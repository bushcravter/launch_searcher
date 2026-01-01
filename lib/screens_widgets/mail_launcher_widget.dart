library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_searcher/models/contact_email_entry.dart';
import 'package:launch_searcher/models/global_data.dart';

class MailLauncherWidget extends StatefulWidget {
  const MailLauncherWidget({super.key, required this.searchTerm, this.selectedIndex = -1});

  //
  // input of the search term
  //
  final String searchTerm;
  //
  // selected index
  //
  final int selectedIndex;
  @override
  State<MailLauncherWidget> createState() => _MailLauncherWidgetState();
}

class _MailLauncherWidgetState extends State<MailLauncherWidget> {
  late Future<List<ContactEmailEntry>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = ContactEmailEntry.fromVcfFile('/home/volker/Dokumente/Adressen/contacts.vcf');
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
    return FutureBuilder<List<ContactEmailEntry>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ein Fehler ist aufgetreten: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Anwendungen gefunden.'));
        }

        globalData.contactEmailEntries = snapshot.data!;
        globalData.contactEmailEntries = ContactEmailEntry.filterContactEntries(globalData.contactEmailEntries, widget.searchTerm);
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: ListView.builder(
            itemCount: globalData.contactEmailEntries.length,
            itemBuilder: (context, index) {
              //
              // set the selected contact entry
              //
              globalData.selectedContactEmailEntry = globalData.contactEmailEntries[index];
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
                  globalData.contactEmailEntries[index].name,
                  style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  globalData.contactEmailEntries[index].emailAddress ?? '',
                  style: TextStyle(color: GlobalData().walColors!.special.foreground),
                ),
                onTap: () async {
                  //
                  // start the app
                  //
                  await globalData.contactEmailEntries[index].launch();

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
