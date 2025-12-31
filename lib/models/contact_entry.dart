import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

enum TypeEntry { email, telephone }

/// Eine Datenklasse, die die extrahierten Informationen eines Kontakts
/// aus einer VCF-Datei enthält.
class ContactEntry {
  /// Der vollständige Name des Kontakts.
  final String name;

  /// Die erste gefundene Telefonnummer des Kontakts.
  /// Kann null sein, wenn kein Eintrag vorhanden ist.
  final String? phoneNumber;

  ///
  /// Die erste gefundene E-Mail-Adresse des Kontakts.
  /// Kann null sein, wenn kein Eintrag vorhanden ist.
  ///
  final String? emailAddress;

  ///
  /// Standard-Konstruktor, um eine Instanz manuell zu erstellen.
  ///
  ContactEntry({required this.name, this.phoneNumber, this.emailAddress});

  ///
  /// Ein Factory-Konstruktor, der eine VCF-Zeichenkette entgegennimmt,
  /// diese parst und eine `ContactEntry`-Instanz daraus erstellt.
  ///
  factory ContactEntry.fromVcf(String vcfString) {
    // Erstellt ein VCard-Objekt aus dem rohen String
    final contact = Contact.fromVCard(vcfString);

    // Extrahiert die Daten. Wir nehmen der Einfachheit halber
    // immer den ersten verfügbaren Eintrag für Telefon und E-Mail.
    String name = contact.displayName;
    String? phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;
    String? email = contact.emails.isNotEmpty ? contact.emails.first.address : null;

    // Gibt eine neue Instanz der Klasse mit den extrahierten Daten zurück.

    return ContactEntry(name: name, phoneNumber: phone, emailAddress: email);
  }

  ///
  /// Liest eine VCF-Datei und gibt eine Liste von `ContactEntry`-Objekten zurück.
  /// Berücksichtigt alle Telefonnummern eines Kontakts.
  ///
  static Future<List<ContactEntry>> fromVcfFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final vcfStrings = content.split('END:VCARD');
    final contactEntries = <ContactEntry>[];

    for (final vcfString in vcfStrings) {
      if (vcfString.trim().isNotEmpty) {
        try {
          final vCard = '$vcfString END:VCARD';
          final contact = Contact.fromVCard(vCard);

          if (contact.phones.isNotEmpty) {
            // Für jede Telefonnummer einen eigenen Eintrag erstellen
            for (final phone in contact.phones) {
              final entry = ContactEntry(
                name: contact.displayName,
                phoneNumber: phone.number,
                emailAddress: contact.emails.isNotEmpty ? contact.emails.first.address : null,
              );
              contactEntries.add(entry);
            }
          } else {
            // Kontakt ohne Telefonnummer hinzufügen
            final entry = ContactEntry(
              name: contact.displayName,
              emailAddress: contact.emails.isNotEmpty ? contact.emails.first.address : null,
            );
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
  /// Gibt den Launch-String für die E-Mail-Adresse zurück.
  /// In diesem Fall einfach die rohe E-Mail-Adresse.
  /// Kann null sein, wenn keine E-Mail-Adresse vorhanden ist.
  ///
  String? get emailLaunchString {
    return 'aerc_new_mail $emailAddress';
  }

  ///
  /// Startet die Anwendung, die durch den 'exec'-Befehl definiert ist.
  /// Platzhalter wie %U, %f etc. werden aus dem Befehl entfernt.
  ///
  Future<void> launch({required TypeEntry typEntry}) async {
    // Die Exec-Variable kann Codes wie %U, %F, %f usw. enthalten.
    // Für einen einfachen Start entfernen wir diese vor der Ausführung.
    String command = '';
    debugPrint('debugPrint: ${phoneLaunchString}');
    switch (typEntry) {
      case TypeEntry.email:
        command = emailLaunchString != null ? emailLaunchString!.replaceAll(RegExp(r'\%[UuFfIiCcKk]'), '').trim() : '';
      case TypeEntry.telephone:
        command = phoneLaunchString != null ? phoneLaunchString!.replaceAll(RegExp(r'\%[UuFfIiCcKk]'), '').trim() : '';
    }

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
  static List<ContactEntry> filterContactEntries(List<ContactEntry> allContacts, String searchTerm) {
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
      return contact.name.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList(); // Wichtig: .toList() um ein neues List-Objekt zu erhalten
    return filteredContacts;
  }

  //
  // Eine überschriebene toString-Methode für einfaches Debugging.
  //
  @override
  String toString() {
    return 'ContactEntry(Name: $name, Telefon: $phoneNumber, E-Mail: $emailAddress)';
  }
}
