library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';

//
// pub.dev packages
//
//
// internal packages
//

// import 'package:flutter/services.dart'; // Optional: Für die Flutter Clipboard API
class CliphistEntry {
  /// Der Inhalt des Eintrags aus der Zwischenablage.
  final String code;
  final String content;

  CliphistEntry({required this.content, required this.code});

  /// Erstellt eine Instanz von [CliphistEntry] aus einer einzelnen Textzeile,
  /// die vom 'cliphist list'-Befehl zurückgegeben wird.
  factory CliphistEntry.fromLine(String line) {
    List<String> lineParts = line.split('\t');
    // Da 'cliphist list' jeden Eintrag direkt als eine Zeile ausgibt,
    // ist der Inhalt der Zeile der Inhalt des Eintrags.
    return CliphistEntry(content: lineParts[1], code: lineParts[0]);
  }

  /// Liest die Einträge aus der Zwischenablage-Historie.
  ///
  /// Führt den Befehl `cliphist list` aus und wandelt die Ausgabe in eine
  /// Liste von [CliphistEntry]-Objekten um.
  ///
  /// Wirft eine Exception, wenn der Befehl fehlschlägt oder keine Ausgabe liefert.
  static Future<List<CliphistEntry>> readHistory() async {
    try {
      // Führe den 'cliphist list'-Befehl aus.
      final result = await Process.run('cliphist', ['list']);

      // Prüfe, ob der Befehl erfolgreich war.
      if (result.exitCode != 0) {
        // Gib eine verständlichere Fehlermeldung aus, falls cliphist nicht gefunden wird.
        if (result.stderr.toString().contains('No such file or directory')) {
          throw Exception('"cliphist" wurde nicht gefunden. Ist das Programm installiert und im System-PATH?');
        }
        throw Exception('Fehler beim Ausführen von "cliphist list": ${result.stderr}');
      }

      // Die Ausgabe des Befehls als String.
      final String stdout = result.stdout as String;

      // Wenn die Ausgabe leer ist, gib eine leere Liste zurück.
      if (stdout.trim().isEmpty) {
        return [];
      }

      // Wandle jede Zeile der Ausgabe in ein CliphistEntry-Objekt um.
      // Leere Zeilen am Ende werden ignoriert.
      final lines = stdout.trim().split('\n');
      return lines.map((line) => CliphistEntry.fromLine(line)).toList();
    } catch (e) {
      // Gib den Fehler weiter und logge ihn für die Fehlersuche.
      print('Fehler beim Lesen der Clipboard-Historie: $e');
      rethrow;
    }
  }

  /// **NEUE LAUNCH-METHODE**
  ///
  /// Setzt den Inhalt dieses [CliphistEntry] wieder in die Zwischenablage.
  ///
  /// Verwendet `wl-copy` (für Wayland) oder `xclip` (für X11) über `Process.start`.
  /// Beachte, dass diese Tools auf dem System installiert sein müssen.
  /// Als Alternative könnte auch `Clipboard.setData(ClipboardData(text: content))`
  /// aus `package:flutter/services.dart` verwendet werden, um die Flutter-eigene
  // Zwischenablagen-API zu nutzen. Die `Process.start`-Methode bietet hier
  /// eine direktere Interaktion mit den nativen System-Clipboard-Tools, was
  /// im Kontext von `cliphist` oft bevorzugt wird.
  Future<void> launch() async {
    // Stelle sicher, dass eine ID vorhanden ist.
    if (cliphistCode.isEmpty) {
      throw Exception('CliphistEntry hat keine ID zum Dekodieren.');
    }

    try {
      ProcessResult result;
      //
      // zuerst mit der Ausgabe von cliphist decode den zu kopierenden String bekommen
      //
      result = await Process.run('cliphist', ['decode', cliphistCode]);
      final copyString = result.stdout as String;
      //
      // copy the string
      //
      result = await Process.run('wl-copy', [copyString]);

      debugPrint('Inhalt von Eintrag ID $cliphistCode erfolgreich in die Zwischenablage kopiert.');
    } catch (e) {
      debugPrint('Fehler beim Kopieren des Zwischenablage-Eintrags: $e');
    }
  }

  /// Filtert eine Liste von [CliphistEntry]-Objekten basierend auf einem Suchbegriff.
  ///
  /// Gibt eine neue Liste zurück, die nur die Einträge enthält, deren Inhalt
  /// den [searchTerm] (case-insensitive) enthält.
  static List<CliphistEntry> filterEntries(List<CliphistEntry> entries, String searchTerm) {
    if (searchTerm.isEmpty) {
      return entries; // Wenn kein Suchbegriff vorhanden ist, gib alle Einträge zurück.
    }

    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    return entries.where((entry) {
      return entry.content.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();
  }

  //
  // get the cliphist content for launch
  //
  String get cliphistContent {
    return content;
  }

  //
  // get the cliphist code for launch
  //
  String get cliphistCode {
    return code;
  }

  @override
  String toString() {
    return 'CliphistEntry(content: "$content")';
  }
}
