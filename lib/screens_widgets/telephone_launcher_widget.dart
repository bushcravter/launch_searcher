library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_searcher/models/contact_telephone_entry.dart';
import 'package:launch_searcher/models/global_data.dart';

class TelephoneLauncherWidget extends StatefulWidget {
  const TelephoneLauncherWidget({super.key, required this.searchTerm, this.telephoneSearcherFocus = false});

  //
  // input of the search term
  //
  final String searchTerm;
  //
  // focus result 
  //
  final bool telephoneSearcherFocus;
  @override
  State<TelephoneLauncherWidget> createState() => _TelephoneLauncherWidgetState();
}

class _TelephoneLauncherWidgetState extends State<TelephoneLauncherWidget> {
  late Future<List<ContactTelephoneEntry>> _contactsFuture;
  //
  // focus  for result set
  //
  final List<FocusNode> listFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _contactsFuture = ContactTelephoneEntry.fromVcfFile('/home/volker/Dokumente/Adressen/contacts.vcf');
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
    return FutureBuilder<List<ContactTelephoneEntry>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ein Fehler ist aufgetreten: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Anwendungen gefunden.'));
        }
        globalData.contactTelephoneEntries = snapshot.data!;
        globalData.contactTelephoneEntries = ContactTelephoneEntry.filterContactEntries(globalData.contactTelephoneEntries, widget.searchTerm);
         for (int kindex = 0; kindex < globalData.contactTelephoneEntries.length; kindex++) {
          listFocusNodes.add(FocusNode());
        }
        if (widget.telephoneSearcherFocus) {
          listFocusNodes[0].requestFocus();
        }
       return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: ListView.builder(
            itemCount: globalData.contactTelephoneEntries.length,
            itemBuilder: (context, index) {
              //
              // set the selected contact entry
              //
              globalData.selectedContactTelephoneEntry = globalData.contactTelephoneEntries[index];
              //
              // return the list tiles
              //
              return ListTile(
                focusNode: listFocusNodes[index],
                selected: listFocusNodes[index].hasFocus,
                focusColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                selectedTileColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                selectedColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                hoverColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                tileColor: GlobalData().walColors!.special.background,
                splashColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                title: Text(
                  globalData.contactTelephoneEntries[index].name,
                  style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(globalData.contactTelephoneEntries[index].phoneNumber ?? '', style: TextStyle(color: GlobalData().walColors!.special.foreground)),
                onTap: () async {
                  //
                  // start the app
                  //
                  await globalData.contactTelephoneEntries[index].launch();
          
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
