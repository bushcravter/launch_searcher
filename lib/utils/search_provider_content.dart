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

/// Ein Widget, das basierend auf dem [currentProvider] das entsprechende
/// Content-Widget anzeigt und den [searchTerm] an dieses übergibt.
class SearchProviderContent extends StatelessWidget {
  /// Eine Map von [SearchProvider] zu Funktionen, die ein Widget erstellen.
  ///
  /// Jede Funktion erhält den aktuellen [searchTerm] als Parameter,
  /// sodass das erstellte Widget auf den Suchbegriff reagieren kann.
  final Map<SearchProvider, Widget Function(String searchTerm)> widgetBuilders;

  /// Der aktuell ausgewählte [SearchProvider], der bestimmt, welches
  /// Widget angezeigt wird.
  final SearchProvider currentProvider;

  /// Der aktuelle Suchbegriff, der an das angezeigte Widget übergeben wird.
  final String searchTerm;

  const SearchProviderContent({super.key, required this.widgetBuilders, required this.currentProvider, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    // Versucht, den Widget-Builder für den aktuellen Provider zu finden.
    final builder = widgetBuilders[currentProvider];

    if (builder != null) {
      // Wenn ein Builder gefunden wird, wird er mit dem Suchbegriff aufgerufen.
      return builder(searchTerm);
    } else {
      // Fallback, falls kein passender Builder gefunden wurde.
      return Center(
        child: Text(
          'Kein Content für Provider: ${currentProvider.name} verfügbar.',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
