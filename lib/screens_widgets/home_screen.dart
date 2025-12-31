library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:launch_searcher/models/contact_entry.dart';
//
// pub.dev packages
//
//
// internal packages
//
import 'package:launch_searcher/models/global_data.dart';
import 'package:launch_searcher/screens_widgets/app_launcher_widget.dart';
import 'package:launch_searcher/screens_widgets/mail_launcher_widget.dart';
import 'package:launch_searcher/screens_widgets/prefixed_search_field.dart';
import 'package:launch_searcher/screens_widgets/telephone_launcher_widget.dart';
import 'package:launch_searcher/utils/search_provider_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  // search provider from PrefixedSearchField
  //
  SearchProvider _inputProvider = SearchProvider.app;
  //
  // search string from PrefixedSearchField
  //
  String _inputSearchString = '';
  //
  // submit function
  //
  void searchSubmitted(String inputSearchString) async {
    //
    // launch always the first entry, if the search string is submitted
    //
    switch (_inputProvider) {
      case SearchProvider.app:
        // 
        // start the first app and close the launchSearcher
        //
        await globalData.desktopEntries[0].launch();
        exit(0);
      case SearchProvider.telephone:
        // 
        // start the first telephone and close the launchSearcher
        //
        await globalData.contactEntries[0].launch(typEntry: TypeEntry.telephone);
        exit(0);
      case SearchProvider.mail:
      case SearchProvider.clipboard:
      case SearchProvider.emoji:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    // return search
    //
    return Scaffold(
      backgroundColor: GlobalData().walColors!.special.background,
      appBar: AppBar(
        backgroundColor: GlobalData().walColors!.special.background,
        title: Text("Launch Searcher App", style: TextStyle(color: GlobalData().walColors!.special.foreground)),
      ),
      body: Column(
        children: [
          PrefixedSearchField(
            onSubmitted: searchSubmitted,
            onSearchChanged: (SearchProvider provider, String searchTerm) {
              //
              // input search provider
              //
              _inputProvider = provider;
              //
              // input search string
              //
              _inputSearchString = searchTerm;
              setState(() {});
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 120,
            child: SearchProviderContent(
              widgetBuilders: {
                SearchProvider.app: (term) {
                  return AppLauncherWidget(searchTerm: term);
                },
                 SearchProvider.telephone: (term) {
                  return TelephoneLauncherWidget(searchTerm: term);
                },
                  SearchProvider.mail: (term) {
                  return MailLauncherWidget(searchTerm: term);
                },
             },
              currentProvider: _inputProvider,
              searchTerm: _inputSearchString,
            ),
          ),
        ],
      ),
    );
  }
}
