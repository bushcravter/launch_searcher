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
import 'package:launch_searcher/models/emoji_entry.dart';
import 'package:launch_searcher/models/global_data.dart';

class EmojiLauncherWidget extends StatefulWidget {
  const EmojiLauncherWidget({super.key, required this.searchTerm, this.emojiSearcherFocus = false});

  final String searchTerm;
  final bool emojiSearcherFocus;

  @override
  State<EmojiLauncherWidget> createState() => _EmojiLauncherWidgetState();
}

class _EmojiLauncherWidgetState extends State<EmojiLauncherWidget> {
  late List<EmojiEntry> _allEmojis;
  final List<FocusNode> listFocusNodes = [];

  @override
  void initState() {
    debugPrint('debugPrint: init');
    _allEmojis = EmojiEntry.getAllEmojis();
    super.initState();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        exit(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    globalData.emojiEntries = EmojiEntry.filterEmojiEntries(_allEmojis, widget.searchTerm);

    // FocusNodes erstellen, falls sie noch nicht existieren
    while (listFocusNodes.length < globalData.emojiEntries.length) {
      listFocusNodes.add(FocusNode());
    }

    if (widget.emojiSearcherFocus && globalData.emojiEntries.isNotEmpty) {
      listFocusNodes[0].requestFocus();
    }

    if (globalData.emojiEntries.isEmpty) {
      return const Center(child: Text('Keine Emojis gefunden.'));
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: ListView.builder(
        itemCount: globalData.emojiEntries.length,
        itemBuilder: (context, index) {
          final emojiEntry = globalData.emojiEntries[index];
          globalData.selectedEmojiEntry = emojiEntry;

          return ListTile(
            focusNode: listFocusNodes[index],
            selected: listFocusNodes[index].hasFocus,
            focusColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
            selectedTileColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
            selectedColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
            hoverColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
            tileColor: GlobalData().walColors!.special.background,
            splashColor: GlobalData().walColors?.normal.color4.withValues(alpha: 0.3) ?? Colors.blueGrey.withValues(alpha: 0.3),
            leading: Text(
              emojiEntry.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              emojiEntry.name,
              style: TextStyle(color: GlobalData().walColors!.special.foreground, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await emojiEntry.launch();
              exit(0);
            },
          );
        },
      ),
    );
  }
}
