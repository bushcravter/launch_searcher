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
import 'package:launch_searcher/models/global_data.dart';
import 'package:launch_searcher/screens_widgets/app_launcher_widget.dart';
import 'package:launch_searcher/screens_widgets/cliphist_launcher_widget.dart';
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
  // focus for search input and search resulta
  //
  bool searchResultFocusNode = false;
  //
  // search provider from PrefixedSearchField
  //
  SearchProvider _inputProvider = SearchProvider.app;
  //
  // search string from PrefixedSearchField
  //
  String _inputSearchString = '';

  @override
  void initState() {
    super.initState();
  }

  //
  // submit function
  //
  void _searchSubmitted(String inputSearchString) async {
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
        await globalData.contactTelephoneEntries[0].launch();
        exit(0);
      case SearchProvider.mail:
        //
        // start the first email and close the launchSearcher
        //
        await globalData.contactEmailEntries[0].launch();
        exit(0);
      case SearchProvider.clipboard:
        //
        // start the cliphist entry and close the launchSearcher
        //
        await globalData.cliphistEntries[0].launch();
        exit(0);
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
            onSubmitted: _searchSubmitted,
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
                 SearchProvider.clipboard: (term) {
                  return CliphistLauncherWidget(searchTerm: term);
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
