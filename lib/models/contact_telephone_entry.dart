import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

enum TypeEntry { email, telephone }

/// Eine Datenklasse, die die extrahierten Informationen eines Kontakts
/// aus einer VCF-Datei enthält.
class ContactTelephoneEntry {
  /// Der vollständige Name des Kontakts.
  final String name;

  /// Die erste gefundene Telefonnummer des Kontakts.
  /// Kann null sein, wenn kein Eintrag vorhanden ist.
  final String? phoneNumber;

  ///
  /// Standard-Konstruktor, um eine Instanz manuell zu erstellen.
  ///
  ContactTelephoneEntry({required this.name, this.phoneNumber});

  ///
  /// Liest eine VCF-Datei und gibt eine Liste von `ContactEntry`-Objekten zurück.
  /// Berücksichtigt alle Telefonnummern eines Kontakts.
  ///
  static Future<List<ContactTelephoneEntry>> fromVcfFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final vcfStrings = content.split('END:VCARD');
    final contactEntries = <ContactTelephoneEntry>[];

    for (final vcfString in vcfStrings) {
      if (vcfString.trim().isNotEmpty) {
        try {
          final vCard = '$vcfString END:VCARD';
          final contact = Contact.fromVCard(vCard);

          if (contact.phones.isNotEmpty) {
            // Für jede Telefonnummer einen eigenen Eintrag erstellen
            for (final phone in contact.phones) {
              final entry = ContactTelephoneEntry(name: contact.displayName, phoneNumber: phone.number);
              contactEntries.add(entry);
            }
          } else {
            // Kontakt ohne Telefonnummer hinzufügen
            final entry = ContactTelephoneEntry(name: contact.displayName);
            contactEntries.add(entry);
          }
        } catch (e) {
          debugPrint('Fehler beim Parsen eines VCF-Eintrags: $e');
        }
      }
    }
    return contactEntries;
  }

  ///
  /// Gibt den Launch-String für die Telefonnummer zurück.
  /// In diesem Fall einfach die rohe Telefonnummer.
  /// Kann null sein, wenn keine Telefonnummer vorhanden ist.
  ///
  String? get phoneLaunchString {
    String dialNumber = phoneNumber != null ? phoneNumber!.replaceAll(' ', '') : '';
    return 'Telefonnummer_waehlen_Link $dialNumber';
  }

  ///
  /// Startet die Anwendung, die durch den 'exec'-Befehl definiert ist.
  /// Platzhalter wie %U, %f etc. werden aus dem Befehl entfernt.
  ///
  Future<void> launch() async {
    // Die Exec-Variable kann Codes wie %U, %F, %f usw. enthalten.
    // Für einen einfachen Start entfernen wir diese vor der Ausführung.
    String command = '';
    command = phoneLaunchString != null ? phoneLaunchString!.replaceAll(RegExp(r'\%[UuFfIiCcKk]'), '').trim() : '';

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
      debugPrint('Anwendung gestartet: $command');
    } catch (e) {
      debugPrint('Fehler beim Starten von "$command": $e');
      // Hier könnten Sie dem Benutzer eine Fehlermeldung anzeigen.
    }
  }

  ///
  /// Beispiel für das Filtern einer Liste von ContactEntry-Objekten.
  ///
  static List<ContactTelephoneEntry> filterContactEntries(List<ContactTelephoneEntry> allContacts, String searchTerm) {
    if (searchTerm.isEmpty) {
      // Wenn der Suchbegriff leer ist, geben wir alle Apps zurück.
      debugPrint('Suchbegriff ist leer. Zeige alle ${allContacts.length} Kontakte.');
      // return allApps;
    }
    //
    // Konvertiere den Suchbegriff in Kleinbuchstaben für eine case-insensitive Suche
    //
    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    //
    // Filtere die Liste
    //
    final filteredContacts = allContacts.where((contact) {
      // Prüfe, ob der Name der App den Suchbegriff enthält (case-insensitive)
      return contact.name.toLowerCase().contains(lowerCaseSearchTerm) && contact.phoneNumber != null && contact.phoneNumber!.isNotEmpty;
    }).toList(); // Wichtig: .toList() um ein neues List-Objekt zu erhalten
    return filteredContacts;
  }

  //
  // Eine überschriebene toString-Methode für einfaches Debugging.
  //
  @override
  String toString() {
    return 'ContactEntry(Name: $name, Telefon: $phoneNumber)';
  }
}
