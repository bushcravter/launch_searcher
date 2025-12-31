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
import 'package:launch_searcher/models/global_data.dart';

/// Ein Textfeld, das die Benutzereingabe analysiert, um einen
/// [SearchProvider] und einen Suchbegriff zu ermitteln.
///
/// Das Widget erkennt Prefixe (z. B. 'a:'), die mit einem Leerzeichen
/// abgeschlossen werden. Jede Eingabeänderung wird über den
/// [onSearchChanged]-Callback gemeldet.
class PrefixedSearchField extends StatefulWidget {
  /// Wird bei jeder Änderung der Eingabe aufgerufen.
  ///
  /// Liefert den erkannten [SearchProvider] und den reinen [searchTerm].
  final Function(SearchProvider provider, String searchTerm) onSearchChanged;

  /// Optionale Dekoration für das zugrundeliegende TextField.
  final InputDecoration? decoration;

  /// Optionaler FocusNode zur Steuerung des Fokus.
  final FocusNode? focusNode;

  /// mit Enter Aktion durchführen
  final Function(String)? onSubmitted;

  const PrefixedSearchField({super.key, required this.onSearchChanged, this.decoration, this.focusNode, this.onSubmitted});

  @override
  State<PrefixedSearchField> createState() => _PrefixedSearchFieldState();
}

class _PrefixedSearchFieldState extends State<PrefixedSearchField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fügt den Listener hinzu, um auf Textänderungen zu reagieren.
    _controller.addListener(_processInput);
  }

  @override
  void dispose() {
    // Entfernt den Listener und zerstört den Controller, um Speicherlecks zu vermeiden.
    _controller.removeListener(_processInput);
    _controller.dispose();
    super.dispose();
  }

  /// Verarbeitet die aktuelle Eingabe aus dem Textfeld.
  void _processInput() {
    final text = _controller.text;

    // Standardwerte: app-Suche mit dem gesamten Text.
    SearchProvider provider = SearchProvider.app;
    String searchTerm = text;

    // Finde die Position des ersten Leerzeichens.
    final spaceIndex = text.indexOf(' ');

    // Wenn ein Leerzeichen gefunden wurde, analysiere den Prefix.
    if (spaceIndex > 0) {
      // > 0, damit ein Leerzeichen am Anfang ignoriert wird
      final potentialPrefix = text.substring(0, spaceIndex);

      // Prüfe, ob der Prefix in der Map existiert.
      if (searchPrefix.containsKey(potentialPrefix)) {
        provider = searchPrefix[potentialPrefix]!;
        // Der Suchbegriff ist alles nach dem ersten Leerzeichen.
        searchTerm = text.substring(spaceIndex + 1);
      }
    }

    // Rufe den Callback mit den ermittelten Werten auf.
    widget.onSearchChanged(provider, searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    // 
    // Greife auf die geladenen WalColors zu, mit Fallback für den Fall, dass sie null sind.
    //
    final walColors = GlobalData().walColors;
    final defaultBackgroundColor = walColors?.special.background ?? Colors.grey[850];
    final defaultForegroundColor = walColors?.special.foreground ?? Colors.white;
    final defaultHintColor = defaultForegroundColor;
    // 
    // return widget
    //
    return TextField(
      onSubmitted: widget.onSubmitted,
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: true,
      style: TextStyle(color: defaultForegroundColor),
      decoration:
          widget.decoration ??
          InputDecoration(
            // HINZUFÜGEN: Hintergrundfarbe des Textfeldes
            filled: true, // Muss true sein, damit fillColor funktioniert
            fillColor: defaultBackgroundColor,

            // HINZUFÜGEN: Farbe des Hint-Textes
            hintText: 'Suche nach Apps, Mails, Kontakten...',
            hintStyle: TextStyle(color: defaultHintColor),
            // Die anderen Dekorationen bleiben gleich
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0)),
              borderSide: BorderSide.none, // Optional: keine sichtbare Umrandung
            ),
            // Setzt die Farbe für den Fokusrahmen, falls vorhanden (z.B. bei OutlineInputBorder)
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: walColors?.normal.color4 ?? Colors.blue, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: defaultBackgroundColor!, width: 0.0), // Gleiche Farbe wie Hintergrund
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ), // Weitere Konfigurationen wie autofocus, style etc. können hier hinzugefügt werden.
    );
  }
}
