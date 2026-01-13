library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:launch_searcher/models/global_data.dart';
//
// pub.dev packages
//
//
// internal packages
//

/// Eine Datenklasse, die die eingelesenen Informationen aus einer .desktop-Datei enthält.
///
/// Sie speichert den Namen, den Ausführungsbefehl und ein fertiges Icon-Widget
/// für die direkte Verwendung in der Flutter-UI.
class DesktopEntry {
  final String name;
  final Widget iconWidget;
  final String exec;
  final String filePath;

  // Privater Konstruktor, der über die asynchrone Factory `fromFile` aufgerufen wird.
  DesktopEntry._({required this.name, required this.iconWidget, required this.exec, required this.filePath});

  ///
  /// Startet die Anwendung, die durch den 'exec'-Befehl definiert ist.
  /// Platzhalter wie %U, %f etc. werden aus dem Befehl entfernt.
  ///
  Future<void> launch() async {
    // Die Exec-Variable kann Codes wie %U, %F, %f usw. enthalten.
    // Für einen einfachen Start entfernen wir diese vor der Ausführung.
    final command = exec.replaceAll(RegExp(r'\%[UuFfIiCcKk]'), '').trim();

    try {
      // Zerlegt den Befehl in das Kommando und die Argumente.
      final parts = command.split(' ');
      final executable = parts.first;
      final arguments = parts.length > 1 ? parts.sublist(1) : <String>[];

      // Startet den Prozess losgelöst (detached), damit die Flutter-App nicht darauf wartet.
      await Process.start(
        executable,
        arguments,
        runInShell: true, // runInShell hilft, Befehle im System-PATH zu finden
        mode: ProcessStartMode.detached,
      );
      debugPrint('Anwendung gestartet: $name $command $arguments');
    } catch (e) {
      debugPrint('Fehler beim Starten von "$name $command": $e');
      // Hier könnten Sie dem Benutzer eine Fehlermeldung anzeigen.
    }
  }

  /// Asynchrone Factory-Methode zum Erstellen einer Instanz aus einer .desktop-Datei.
  ///
  /// Liest die Datei, parst die relevanten Felder und erstellt das [iconWidget].
  /// Gibt `null` zurück, wenn die Datei nicht erfolgreich geparst werden kann
  /// oder für die Anzeige ungeeignet ist (z.B. `NoDisplay=true`).
  static Future<DesktopEntry?> fromFile(File file, {double iconSize = 48.0}) async {
    try {
      final lines = await file.readAsLines();
      String? name;
      String? icon;
      String? exec;

      // Einfaches Parsen der .desktop-Datei
      for (final line in lines) {
        if (line.contains('=')) {
          final parts = line.split('=');
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          switch (key) {
            case 'Name':
              name ??= value;
              break;
            case 'Icon':
              icon ??= value;
              break;
            case 'Exec':
              exec ??= value;
              break;
          }
        }
      }

      // Einträge mit `NoDisplay=true` überspringen
      if (lines.any((l) => l.trim() == 'NoDisplay=true')) {
        return null;
      }

      if (name != null && name.isNotEmpty && exec != null && exec.isNotEmpty) {
        final iconWidget = await _createIconWidget(icon, iconSize);
        return DesktopEntry._(name: name, iconWidget: iconWidget, exec: exec, filePath: file.path);
      }
    } catch (e) {
      debugPrint('Fehler beim Parsen von ${file.path}: $e');
    }
    return null;
  }

  /// Private Hilfsmethode zur Erstellung des Icon-Widgets.
  ///
  /// Sucht nach dem Icon basierend auf dem Namen oder Pfad und gibt ein
  /// passendes `Image` oder ein `Icon`-Platzhalter-Widget zurück.
  static Future<Widget> _createIconWidget(String? iconNameOrPath, double size) async {
    iconNameOrPath ??= 'application-x-executable'; // Fallback-Icon-Name

    // 1. Prüfen, ob der Wert ein absoluter Pfad ist
    if (iconNameOrPath.startsWith('/')) {
      final file = File(iconNameOrPath);
      if (await file.exists()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: size),
        );
      }
    }

    // Vereinfachte Suche in Standard-Icon-Verzeichnissen.
    // Eine vollständige Implementierung würde die `index.theme`-Dateien parsen.
    final searchPaths = [
      '/usr/share/pixmaps',
      '/usr/share/icons/hicolor/scalable/apps',
      '/usr/share/icons/hicolor/128x128/apps',
      '/usr/share/icons/hicolor/64x64/apps',
      '/usr/share/icons/hicolor/48x48/apps',
      '${Platform.environment['HOME']}/.local/share/icons/hicolor/48x48/apps',
    ];

    for (final path in searchPaths) {
      // Suche mit gängigen Erweiterungen, bevorzuge Vektorgrafiken
      for (final ext in ['.svg', '.png', '']) {
        final file = File('$path/$iconNameOrPath$ext');
        final fileWithoutExt = File('$path/$iconNameOrPath.svg');
        if ((ext == '') && (await fileWithoutExt.exists())) {
          try {
            return SvgPicture.file(
              File('$path/$iconNameOrPath.svg'),
              width: size,
              height: size,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(Icons.apps, size: size), // Platzhalter während des Ladens
            );
          } catch (error) {
            debugPrint('debugPrint: ${error.toString()}');
          }
        } else if (await file.exists()) {
          if (ext == '.svg') {
            return SvgPicture.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(Icons.apps, size: size), // Platzhalter während des Ladens
            );
          } else {
            return Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: size),
            );
          }
        }
      }
    }

    // 3. Wenn kein Icon gefunden wurde, ein Standard-Icon zurückgeben
    return Icon(Icons.apps, size: size, color: GlobalData().walColors!.special.foreground);
  }

  ///
  /// Beispiel für das Filtern einer Liste von DesktopEntry-Objekten.
  ///
  static List<DesktopEntry> filterDesktopEntries(List<DesktopEntry> allApps, String searchTerm) {
    if (searchTerm.isEmpty) {
      // Wenn der Suchbegriff leer ist, geben wir alle Apps zurück.
      debugPrint('Suchbegriff ist leer. Zeige alle ${allApps.length} Apps.');
      // return allApps;
    }
    //
    // Konvertiere den Suchbegriff in Kleinbuchstaben für eine case-insensitive Suche
    //
    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    //
    // Filtere die Liste
    //
    final filteredApps = allApps.where((app) {
      // Prüfe, ob der Name der App den Suchbegriff enthält (case-insensitive)
      return app.name.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList(); // Wichtig: .toList() um ein neues List-Objekt zu erhalten
    //
    // sortiere die Liste
    //
    filteredApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filteredApps;
  }
}
