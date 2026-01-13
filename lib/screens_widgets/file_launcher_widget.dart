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
import 'package:launch_searcher/models/file_entry.dart';
import 'package:launch_searcher/models/global_data.dart';

class FileLauncherWidget extends StatefulWidget {
  const FileLauncherWidget({super.key, required this.searchTerm, this.fileSearcherFocus = false});

  //
  // input of the search term
  //
  final String searchTerm;
  //
  // focus for result
  //
  final fileSearcherFocus;

  @override
  State<FileLauncherWidget> createState() => _FileLauncherWidgetState();
}

class _FileLauncherWidgetState extends State<FileLauncherWidget> {
  late Future<List<FileEntry>> _fileFuture;
  //
  // focus for result set
  //
  final List<FocusNode> listFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _fileFuture = FileEntry.readFiles();
  }

  //
  // This method is called on every key press
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
    return FutureBuilder<List<FileEntry>>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error has occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No files found.'));
        }
        globalData.fileEntries = snapshot.data!;
        globalData.fileEntries = FileEntry.filterEntries(globalData.fileEntries, widget.searchTerm);
        for (int kindex = 0; kindex < globalData.fileEntries.length; kindex++) {
          listFocusNodes.add(FocusNode());
        }
        if (widget.fileSearcherFocus) {
          if (listFocusNodes.isNotEmpty) {
            listFocusNodes[0].requestFocus();
          }
        }
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: _handleKeyEvent,
          child: ListView.builder(
            itemCount: globalData.fileEntries.length,
            itemBuilder: (context, index) {
              //
              // set the selected file entry
              //
              globalData.selectedFileEntry = globalData.fileEntries[index];
              //
              // return the list tiles
              //
              return Column(
                children: [
                  ListTile(
                    focusNode: listFocusNodes[index],
                    selected: listFocusNodes[index].hasFocus,
                    focusColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                    selectedTileColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                    selectedColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                    tileColor: GlobalData().walColors!.special.background,
                    splashColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
                    title: Text(
                      globalData.fileEntries[index].filename,
                      style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      globalData.fileEntries[index].path,
                      style: TextStyle(color: GlobalData().walColors!.special.foreground),
                    ),
                    onTap: () async {
                      //
                      // open the file
                      //
                      await globalData.fileEntries[index].launch();
                      //
                      // close the LaunchSearcher
                      //
                      exit(0);
                    },
                  ),
                  SizedBox(height: 8,),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
