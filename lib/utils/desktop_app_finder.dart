library;
// 
// Flutter packages
//
import 'dart:io';
//
// pub.dev packages
//
import 'package:launch_searcher/models/desktop_entry.dart';
//
// internal packages
//

/// 
/// Ein Service zum Finden und Parsen von .desktop-Dateien unter Linux.
///
class DesktopAppFinder {
  /// Durchsucht Standardverzeichnisse nach .desktop-Dateien und gibt eine Liste
  /// von [DesktopEntry]-Objekten zurück.
  Future<List<DesktopEntry>> findAndParseApps({double iconSize = 48.0}) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      return []; // Home-Verzeichnis nicht gefunden
    }

    final searchDirs = [Directory('/usr/share/applications'), Directory('$homeDir/.local/share/applications')];

    final futures = <Future<DesktopEntry?>>[];
    final seenAppFileNames = <String>{};

    for (final dir in searchDirs) {
      if (await dir.exists()) {
        // Rekursiv alle Dateien im Verzeichnis auflisten
        await for (final fileEntity in dir.list(recursive: true)) {
          if (fileEntity is File && fileEntity.path.endsWith('.desktop')) {
            final fileName = fileEntity.path.split('/').last;
            // Verhindert Duplikate, falls eine App systemweit und für den Benutzer installiert ist
            if (seenAppFileNames.add(fileName)) {
              futures.add(DesktopEntry.fromFile(fileEntity, iconSize: iconSize));
            }
          }
        }
      }
    }

    // Warte, bis alle Dateien parallel verarbeitet wurden
    final results = await Future.wait(futures);
    // Filtere alle `null`-Ergebnisse heraus und erstelle die finale Liste
    final apps = results.whereType<DesktopEntry>().toList();

    // Sortiert die Liste alphabetisch nach dem Anwendungsnamen
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return apps;
  }
}
