// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  var themeIndex = 0;
  var themeData = ThemeData.dark();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      title: 'Startup Name Generator',
      home: RandomWords(this),
    );
  }

  void toggleTheme() {
    setState(() {
      themeIndex++;
      themeData = themeIndex.isOdd ? ThemeData.light() : ThemeData.dark();
    });
  }
}

class RandomWords extends StatefulWidget {
  final MyAppState myAppState;

  RandomWords(this.myAppState);

  @override
  State<StatefulWidget> createState() => RandomWordsState(myAppState);
}

class RandomWordsState extends State<StatefulWidget> {
  final _generated = <WordPair>[];
  final _saved = Set<WordPair>();

  final MyAppState myAppState;

  RandomWordsState(this.myAppState);

  WordPair _getOrCreateWordPair(int i) {
    while (i >= _generated.length) {
      _generated.add(WordPair.random());
    }

    return _generated[i];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.format_paint),
              onPressed: () {
                myAppState.toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                _navigateToSaved();
              },
            )
          ],
        ),
        body: _buildListView(),
      );

  ListView _buildListView() {
    return ListView.builder(itemBuilder: (context, i) {
      if (i.isOdd) {
        return Divider();
      }

      var wordPair = _getOrCreateWordPair(i);
      var subtitle = "Item #${i ~/ 2}";

      return _buildListItem(subtitle, wordPair);
    });
  }

  ListTile _buildListItem(String subtitle, WordPair wordPair) {
    var isSaved = _saved.contains(wordPair);
    return ListTile(
      title: Text(wordPair.asPascalCase),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? Colors.red : null,
        ),
        onPressed: () => setState(() {
          _toggleSaved(wordPair);
        }),
      ),
    );
  }

  void _toggleSaved(WordPair wordPair) {
    bool added = _saved.add(wordPair);
    if (added) {
      // good
    } else {
      // we actually needed to remove it, do it
      _saved.remove(wordPair);
    }

    log("Saved: $_saved");
  }

  void _navigateToSaved() {
    Navigator.of(context)
        // CupertinoPageRoute slides left/right, MaterialPageRoute slides up/down
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(title: Text("Saved names")),
          body: ListView(children: makeSavedTiles(context)));
    }));
  }

  List<Widget> makeSavedTiles(BuildContext context) {
    return ListTile.divideTiles(
            context: context,
            tiles: _saved.map(
                (WordPair pair) => ListTile(title: Text(pair.asPascalCase))))
        .toList();
  }
}
