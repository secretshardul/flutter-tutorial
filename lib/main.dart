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

// Widget's build() function is moved to a new class
// Stateful widget only has a createState()
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Note the underscore- _MyHomePageState. Flutter compiler ensures that contents
// of this class remain private
class _MyHomePageState extends State<MyHomePage> {
  // State variable
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Obtain page based on state- do this inside build()
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;

      case 1:
        page = FavouritesPage();
        break;

      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
              extended: constraints.maxWidth > 600,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text("Home")),
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text("Favourites"))
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                // Important- don't set value directly, but set inside setState()
                setState(() {
                  selectedIndex = value;
                });
              },
            )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ))
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch state changes
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // Do not repeat scaffold in nested widget, otherwise theme won't apply
    return Center(
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

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();

    var favouritesList = appState.favourites
        .map((e) => ListTile(
              leading: Icon(Icons.favorite),
              title: Text(e.asLowerCase),
            ))
        .toList();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favourites.length} favorites:'),
        ),
        ...favouritesList,
      ],
    );
  }
}
