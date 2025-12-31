library;
// 
// Flutter packages
//
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:launch_searcher/models/contact_entry.dart';
import 'package:launch_searcher/models/desktop_entry.dart';
//
// pub.dev packages
//
//
// internal packages
//

//
// search provider for the home screen
//
enum SearchProvider { app, mail, telephone, clipboard, emoji }

//
// search prefix with corresponding search provider
//
Map<String, SearchProvider> searchPrefix = {
  'a': SearchProvider.app,
  'm': SearchProvider.mail,
  't': SearchProvider.telephone,
  'c': SearchProvider.clipboard,
  'e': SearchProvider.emoji,
};


//
// singleton instance of GlobalData
//
GlobalData globalData = GlobalData();

//
// data class
//
class GlobalData {
  /// Das geladene Pywal-Farbthema. Ist `null`, bis `loadWalTheme()` aufgerufen wurde.
  WalColors? walColors;

  // --- Singleton Implementierung ---
  static final GlobalData _instance = GlobalData._internal();

  factory GlobalData() {
    return _instance;
  }

  GlobalData._internal();
  // --- Ende Singleton ---
  

  //
  // search result items
  //
  // apps
  List<DesktopEntry> desktopEntries = []; 
  DesktopEntry? selectedDesktopEntry; 
  // contact data
  List<ContactEntry> contactEntries = [];
  ContactEntry? selectedContactEntry;
  
  /// Lädt das Pywal-Farbthema aus der `colors.json`-Datei.
  ///
  /// Diese Methode sollte einmal beim Start der App aufgerufen werden,
  /// z.B. in der `main()`-Funktion.
  Future<void> loadWalTheme() async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      debugPrint('HOME environment variable not found. Cannot load Wal theme.');
      return;
    }

    final path = '$homeDir/.cache/wal/colors.json';
    final file = File(path);

    if (!await file.exists()) {
      debugPrint('Pywal colors.json not found at: $path');
      return;
    }

    try {
      final content = await file.readAsString();
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      walColors = WalColors.fromJson(jsonMap);
      debugPrint('Pywal theme loaded successfully.');
    } catch (e) {
      debugPrint('Error loading or parsing Pywal colors.json: $e');
      walColors = null;
    }
  }
}

// -----------------------------------------------------------------------------
// Pywal Farb-Datenklassen (jetzt Teil von global_data.dart)
// -----------------------------------------------------------------------------

/// Konvertiert einen Hex-Farbstring (z.B. "#RRGGBB") in ein Flutter Color-Objekt.
Color _hexToColor(String hexString) {
  final hex = hexString.replaceFirst('#', '');
  final fullHex = 'FF$hex';
  return Color(int.parse(fullHex, radix: 16));
}

/// Die Hauptdatenklasse, die alle Pywal-Farben enthält.
@immutable
class WalColors {
  final SpecialWalColors special;
  final NormalWalColors normal;

  const WalColors({required this.special, required this.normal});

  factory WalColors.fromJson(Map<String, dynamic> json) {
    return WalColors(
      special: SpecialWalColors.fromJson(json['special'] as Map<String, dynamic>),
      normal: NormalWalColors.fromJson(json['colors'] as Map<String, dynamic>),
    );
  }
}

/// Datenklasse für die speziellen Pywal-Farben.
@immutable
class SpecialWalColors {
  final Color background;
  final Color foreground;
  final Color cursor;

  const SpecialWalColors({required this.background, required this.foreground, required this.cursor});

  factory SpecialWalColors.fromJson(Map<String, dynamic> json) {
    return SpecialWalColors(
      background: _hexToColor(json['background'] as String),
      foreground: _hexToColor(json['foreground'] as String),
      cursor: _hexToColor(json['cursor'] as String),
    );
  }
}

/// Datenklasse für die normalen 16 Pywal-Farben.
@immutable
class NormalWalColors {
  final Color color0;
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Color color5;
  final Color color6;
  final Color color7;
  final Color color8;
  final Color color9;
  final Color color10;
  final Color color11;
  final Color color12;
  final Color color13;
  final Color color14;
  final Color color15;

  const NormalWalColors({
    required this.color0,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.color5,
    required this.color6,
    required this.color7,
    required this.color8,
    required this.color9,
    required this.color10,
    required this.color11,
    required this.color12,
    required this.color13,
    required this.color14,
    required this.color15,
  });

  factory NormalWalColors.fromJson(Map<String, dynamic> json) {
    return NormalWalColors(
      color0: _hexToColor(json['color0'] as String),
      color1: _hexToColor(json['color1'] as String),
      color2: _hexToColor(json['color2'] as String),
      color3: _hexToColor(json['color3'] as String),
      color4: _hexToColor(json['color4'] as String),
      color5: _hexToColor(json['color5'] as String),
      color6: _hexToColor(json['color6'] as String),
      color7: _hexToColor(json['color7'] as String),
      color8: _hexToColor(json['color8'] as String),
      color9: _hexToColor(json['color9'] as String),
      color10: _hexToColor(json['color10'] as String),
      color11: _hexToColor(json['color11'] as String),
      color12: _hexToColor(json['color12'] as String),
      color13: _hexToColor(json['color13'] as String),
      color14: _hexToColor(json['color14'] as String),
      color15: _hexToColor(json['color15'] as String),
    );
  }

  List<Color> get allColors => [
    color0,
    color1,
    color2,
    color3,
    color4,
    color5,
    color6,
    color7,
    color8,
    color9,
    color10,
    color11,
    color12,
    color13,
    color14,
    color15,
  ];
}
