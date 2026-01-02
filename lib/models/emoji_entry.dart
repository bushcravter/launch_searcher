import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Eine Datenklasse, die ein Emoji und seinen Namen enthält.
class EmojiEntry {
  /// Der Name/die Beschreibung des Emojis.
  final String name;

  /// Das Emoji-Zeichen selbst.
  final String emoji;

  /// Standard-Konstruktor.
  EmojiEntry({required this.name, required this.emoji});

  /// Gibt eine statische Liste aller verfügbaren Emojis zurück.
  static List<EmojiEntry> getAllEmojis() {
    final List<EmojiEntry> emojiEntries = [];

    // Das Paket 'emojis' stellt eine globale Konstante 'Emojis' bereit.
    // Emojis.all enthält eine Liste aller Emoji-Objekte.
    for (var emoji in Emoji.all()) {
      emojiEntries.add(EmojiEntry(name: emoji.name, emoji: emoji.char));
    }

    return emojiEntries;
  }

  /// Kopiert das Emoji in die Zwischenablage.
  Future<void> launch() async {
    try {
      await Clipboard.setData(ClipboardData(text: emoji));
      debugPrint('Emoji in die Zwischenablage kopiert: $emoji');
    } catch (e) {
      debugPrint('Fehler beim Kopieren in die Zwischenablage: $e');
    }
  }

  /// Filtert eine Liste von Emojis basierend auf einem Suchbegriff.
  static List<EmojiEntry> filterEmojiEntries(List<EmojiEntry> allEmojis, String searchTerm) {
    if (searchTerm.isEmpty) {
      return allEmojis;
    }

    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    return allEmojis.where((entry) {
      return entry.name.toLowerCase().contains(lowerCaseSearchTerm) || entry.emoji.contains(lowerCaseSearchTerm);
    }).toList();
  }

  @override
  String toString() {
    return 'EmojiEntry(Name: $name, Emoji: $emoji)';
  }
}
