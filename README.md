# Flutter tutorial

## Steps

- Cleanup pubspec.yaml. Install `english_words` and `provider`
- Setup linter options in `analysis_options.yaml`

## Theory

- **Widget**: A widget is an element used to build a flutter app. The flutter app itself is a widget.

- The main function loads the App widget

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Setup app details by overriding build()
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        // Name
        title: 'Namer App',
        // Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // Home widget
        home: MyHomePage(),
      ),
    );
  }
}

// Global state
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}
```

- `MyApp` sets up the app by defining the name, theme, global state and home page widget

- `MyAppState` uses `ChangeNotifier`.  This allows deeply nested widgets to listen to changes.

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch state changes
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text('A random awesome idea:'),
          // Read `current` from global state
          Text(appState.current.asLowerCase),
          ElevatedButton(
              onPressed: () {
                print("button pressed");
              },
              child: Text("Next"))
        ],
      ),
    );
  }
}
```

- `AppState` can host functions which can be called by listener widgets

```dart
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    // Update current word
    current = WordPair.random();

    // Notify changes to subscribers- important otherwise changes wont reflect
    // in children
    notifyListeners();
  }
}

// In MyHomePage > Scaffold
          ElevatedButton(
              onPressed: () {
                print("button pressed");

                // Update word
                appState.getNext();
              },
              child: Text("Next")
            )
```

### Creating custom widgets

- Press refactor > extract widget to turn `Text(pair.asLowerCase)` into a new widget. Then add padding and wrap it into a card widget.

```dart
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    // Props passed to widget- required means compulsory
    required this.pair,
  });

  // final keyword- widget cannot change this value
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(pair.asLowerCase),
      ),
    );
  }
}
```

- Flutter prefers **composition over inheritance**. Padding is not an overwritten property of `Text` but is instad a separate widget.

  - In other frameworks

  ```dart
  Text(
    text: "Hello, World!",
    padding: EdgeInsets.all(16.0),
  )
  ```

  - In flutter

  ```dart
  Padding(
    padding: EdgeInsets.all(16.0),
    child: Text("Hello, World!"),
  )
  ```

- Reading theme- Use `Theme.of(context)` in `build()`

```dart
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

    return Card(
      // colorScheme is set in MyApp > MaterialApp > Theme
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(pair.asLowerCase),
      ),
    );
  }
}
```

## Alignment

- To align vertically, add `mainAxisAlignment: MainAxisAlignment.center` to Scaffold > Column

- To align horizontally, wrap Column with `Center`

```dart
    return Scaffold(
      // Nest Column inside Center to center horizontally
      body: Center(
        child: Column(
          // Center vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A random awesome idea:'),
            BigCard(pair: pair),
```

