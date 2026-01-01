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
import 'package:launch_searcher/models/cliphist_entry.dart';

/// Eine Klasse, die die Zwischenablagen-Historie mit dem 'cliphist'-Befehlszeilentool liest.
class ClipboardHistoryReader {
  /// Liest die Einträge aus der Zwischenablage-Historie.
  ///
  /// Führt den Befehl `cliphist list` aus und wandelt die Ausgabe in eine
  /// Liste von [CliphistEntry]-Objekten um.
  ///
  /// Wirft eine Exception, wenn der Befehl fehlschlägt oder keine Ausgabe liefert.
  Future<List<CliphistEntry>> readHistory() async {
    try {
      // Führe den 'cliphist list'-Befehl aus.
      final result = await Process.run('cliphist', ['list']);

      // Prüfe, ob der Befehl erfolgreich war.
      if (result.exitCode != 0) {
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
      // Gib den Fehler weiter, falls etwas schiefgeht (z.B. 'cliphist' nicht installiert).
      debugPrint('Fehler beim Lesen der Clipboard-Historie: $e');
      rethrow;
    }
  }
}
