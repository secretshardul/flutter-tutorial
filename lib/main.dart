import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var favourites = <WordPair>[];

  void getNext() {
    // Update current word
    current = WordPair.random();

    // Notify changes to subscribers- important otherwise changes wont reflect
    // in children
    notifyListeners();
  }

  void toggleFavourite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }

    // Don't forget notifyListeners
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch state changes
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      // Nest Column inside Center to center horizontally
      body: Center(
        child: Column(
          // Center vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            // Add padding
            SizedBox(height: 60),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LikeButton(appState: appState),
                SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      print("button pressed");

                      // Update word
                      appState.getNext();
                    },
                    child: Text("Next")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    var pair = appState.current;

    IconData icon;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return ElevatedButton.icon(
        icon: Icon(icon),
        onPressed: () {
          appState.toggleFavourite();
        },
        label: Text("Like"));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    // Props passed to widget
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // Read theme from context. Theme is not read from props, but instead from
    // context in `build()`
    final theme = Theme.of(context);

    // Create a copy of `displayMedium` theme and replace the color field
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      // colorScheme is set in MyApp > MaterialApp > Theme
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(pair.asLowerCase,
            style: style,
            // Semantics label is used for talkback. It is not visible to users
            semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}
