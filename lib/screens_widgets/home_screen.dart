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
import 'package:launch_searcher/screens_widgets/emoji_launcher_widget.dart';
import 'package:launch_searcher/screens_widgets/file_launcher_widget.dart';
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
  // title string
  //
  String titleString = 'Anwendungen';
  //
  // search provider from PrefixedSearchField
  //
  SearchProvider _inputProvider = SearchProvider.app;
  //
  // search string from PrefixedSearchField
  //
  String _inputSearchString = '';
  //
  // app searcher focus node
  //
  bool searcherFocusNode = false;
  //
  // selected index of the result
  //
  int selectedIndex = -1;

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
        //
        // start the emoji entry and close the launchSearcher
        //
        await globalData.emojiEntries[0].launch();
        exit(0);
      case SearchProvider.file:
        //
        // start the file entry and close the launchSearcher
        //
        await globalData.fileEntries[0].launch();
        exit(0);
    }
  }

  //
  // focus for result
  //
  void _focusResult() {
    searcherFocusNode = !searcherFocusNode;
    setState(() {});
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
        title: Text(titleString, style: TextStyle(color: GlobalData().walColors!.special.foreground)),
      ),
      body: Column(
        children: [
          PrefixedSearchField(
            onSubmitted: _searchSubmitted,
            focusResult: _focusResult,
            onSearchChanged: (SearchProvider provider, String searchTerm) {
              switch (provider) {
                case SearchProvider.app:
                  titleString = '󰙵   Anwendungen';
                  break;
                case SearchProvider.mail:
                  titleString = '󰺻   E-Mail';
                  break;
                case SearchProvider.telephone:
                  titleString = '   Telefon';
                  break;
                case SearchProvider.clipboard:
                  titleString = '   Zwischenablage';
                  break;
                case SearchProvider.emoji:
                  titleString = '󰞅   Emojis';
                  break;
                case SearchProvider.file:
                  titleString = '   Dateien';
                  break;
              }
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
                  return AppLauncherWidget(searchTerm: term, appSearcherFocus: searcherFocusNode);
                },
                SearchProvider.telephone: (term) {
                  return TelephoneLauncherWidget(searchTerm: term, telephoneSearcherFocus: searcherFocusNode);
                },
                SearchProvider.mail: (term) {
                  return MailLauncherWidget(searchTerm: term, mailSearcherFocus: searcherFocusNode);
                },
                SearchProvider.clipboard: (term) {
                  return CliphistLauncherWidget(searchTerm: term, clipSearcherFocus: searcherFocusNode);
                },
                SearchProvider.emoji: (term) {
                  return EmojiLauncherWidget(searchTerm: term, emojiSearcherFocus: searcherFocusNode);
                },
                SearchProvider.file: (term) {
                  return FileLauncherWidget(searchTerm: term, fileSearcherFocus: searcherFocusNode);
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
