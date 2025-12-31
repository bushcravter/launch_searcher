library;
// 
// Flutter packages
//
import 'package:flutter/material.dart';
//
// pub.dev packages
//
//
// internal packages
//

/// Konvertiert einen Hex-Farbstring (z.B. "#RRGGBB" oder "RRGGBB") in ein Flutter Color-Objekt.
/// Fügt bei Bedarf ein Alpha von 0xFF (deckend) hinzu.
Color _hexToColor(String hexString) {
  // Entferne das '#' Präfix, falls vorhanden
  final hex = hexString.replaceFirst('#', '');
  // Füge das Alpha-Präfix hinzu, falls es fehlt (ARGB-Format)
  final fullHex = 'FF$hex';
  return Color(int.parse(fullHex, radix: 16));
}

/// Datenklasse für die speziellen Pywal-Farben (Hintergrund, Vordergrund, Cursor).
@immutable
class SpecialWalColors {
  final Color background;
  final Color foreground;
  final Color cursor;

  const SpecialWalColors({required this.background, required this.foreground, required this.cursor});

  /// Erstellt eine [SpecialWalColors] Instanz aus einem JSON-Map.
  factory SpecialWalColors.fromJson(Map<String, dynamic> json) {
    return SpecialWalColors(
      background: _hexToColor(json['background'] as String),
      foreground: _hexToColor(json['foreground'] as String),
      cursor: _hexToColor(json['cursor'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialWalColors &&
          runtimeType == other.runtimeType &&
          background == other.background &&
          foreground == other.foreground &&
          cursor == other.cursor;

  @override
  int get hashCode => background.hashCode ^ foreground.hashCode ^ cursor.hashCode;
}

/// Datenklasse für die normalen 16 Pywal-Farben (color0 bis color15).
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

  /// Erstellt eine [NormalWalColors] Instanz aus einem JSON-Map.
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

  // Für Test- und Debugging-Zwecke können Sie hier einen Getter für die Liste der Farben hinzufügen
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NormalWalColors &&
          runtimeType == other.runtimeType &&
          color0 == other.color0 &&
          color1 == other.color1 &&
          color2 == other.color2 &&
          color3 == other.color3 &&
          color4 == other.color4 &&
          color5 == other.color5 &&
          color6 == other.color6 &&
          color7 == other.color7 &&
          color8 == other.color8 &&
          color9 == other.color9 &&
          color10 == other.color10 &&
          color11 == other.color11 &&
          color12 == other.color12 &&
          color13 == other.color13 &&
          color14 == other.color14 &&
          color15 == other.color15;

  @override
  int get hashCode =>
      color0.hashCode ^
      color1.hashCode ^
      color2.hashCode ^
      color3.hashCode ^
      color4.hashCode ^
      color5.hashCode ^
      color6.hashCode ^
      color7.hashCode ^
      color8.hashCode ^
      color9.hashCode ^
      color10.hashCode ^
      color11.hashCode ^
      color12.hashCode ^
      color13.hashCode ^
      color14.hashCode ^
      color15.hashCode;
}

/// Die Hauptdatenklasse, die alle Pywal-Farben enthält.
@immutable
class WalColors {
  final SpecialWalColors special;
  final NormalWalColors normal;

  const WalColors({required this.special, required this.normal});

  /// Erstellt eine [WalColors] Instanz aus einem JSON-Map.
  factory WalColors.fromJson(Map<String, dynamic> json) {
    return WalColors(
      special: SpecialWalColors.fromJson(json['special'] as Map<String, dynamic>),
      normal: NormalWalColors.fromJson(json['colors'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WalColors && runtimeType == other.runtimeType && special == other.special && normal == other.normal;

  @override
  int get hashCode => special.hashCode ^ normal.hashCode;
}
