library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:launch_searcher/models/contact_entry.dart';
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
  late Future<List<ContactEntry>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = ContactEntry.fromVcfFile('/home/volker/Dokumente/Adressen/contacts.vcf');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContactEntry>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ein Fehler ist aufgetreten: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Anwendungen gefunden.'));
        }

        globalData.contactEntries = snapshot.data!;
        globalData.contactEntries = ContactEntry.filterContactEntries(globalData.contactEntries, widget.searchTerm);
        return ListView.builder(
          itemCount: globalData.contactEntries.length,
          itemBuilder: (context, index) {
            //
            // set the selected contact entry
            //
            globalData.selectedContactEntry = globalData.contactEntries[index];
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
                globalData.contactEntries[index].name,
                style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(globalData.contactEntries[index].emailAddress ?? '', style: TextStyle(color: GlobalData().walColors!.special.foreground)),
              onTap: () async {
                //
                // start the app
                //
                await globalData.contactEntries[index].launch(typEntry: TypeEntry.email);

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
