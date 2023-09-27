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

## Navigation

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            extended: true,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("Home")),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text("Favourites"))
            ],
            selectedIndex: 0,
            onDestinationSelected: (value) {
              print("selected $value");
            },
          )),
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: GeneratorPage(),
          ))
        ],
      ),
    );
  }
}
```

- `SafeArea` ensures that children are not obscured by a notch or status bar
- `extended: true` displays text alongside icons
- `selectedIndex` sets the selected navigation destination
- `onDestinationSelected()` handles clicks on destinations
- `Expanded`: This is greedy area. It takes up all area available that is left free by the Navigation rail

## Stateful widget

- Allows us to store state in the widget itself, without having to use the global state.
- Select widget name > refactor > stateful widget.

  - Before

  ```dart
  class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  ```

  - After

  ```dart
  class MyHomePage extends StatefulWidget {
    @override
    State<MyHomePage> createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<MyHomePage> {
    // Add state here
    @override
    Widget build(BuildContext context) {
      return Scaffold(
  ```

- After adding state
  - Only state variables should be inside `_MyHomePageState`. Since `page` depends on `selectedIndex` we put it inside `build()`
  - `selectedIndex` must be updated in a callback wrapped by `setState()`. This causes the UI to refresh

  ```dart
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
          page = Placeholder();
          break;

        default:
          throw UnimplementedError("no widget for $selectedIndex");
      }

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
              extended: true,
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
    }
  }
  ```

## Responsiveness

- Flutter uses **logical pixels**. They are device independent and produce the same result independent of screen resolution. The app is automatically responsive, however we must handle `NavigationRail` expansion and contraction ourselves.
- Wrap the `Scaffold` with `LayoutBuilder` to gain access to screen `constraints`. The `builder` callback is called every time the screen constraints change

  - Before

  ```dart
  return Scaffold(
    body: Row(
      children: [
  ```

  - After

  ```dart
  return LayoutBuilder(builder: (context, constraints) {
    return Scaffold(
      body: Row(
  ```

  - Set NavigationRail > extended as

  ```dart
  child: NavigationRail(
    extended: constraints.maxWidth > 600,
  ```

## Widget lifecycle callbacks

- `createState()`: Called in stateful objects. Returns a mutable state object for the widget
- `initState()`: Called when a stateful widget is inserted into the widget tree for the first time. Used for one-time initialization tasks such as setting up listeners.
- `build()`: Defines a widget's widget tree. The most important lifecycle method. It can be called from another callback if a rebuild is necessary.
- `didUpdateWidget()`: Called when a widget is updated. It provides the old widget as an argument so you can compare the old and new widgets.
- `didChangeDependencies()`: Called when a widget's dependencies (eg InheritedWidget) have changed
- `deactivate()`: Called when a widget is removed from the widget tree. Used to clean up resources
- `dispose()`: Called when a widget is removed from the tree permanently. This is the last callback for `StatefulWidget`

## State management

- `InheritedWidget`: Allows us to pass data from a parent widget to its descendants without having to pass data explicitly through each descendant. Used for immutable data such as themes. The shared data is immutable- the widget must be recreated in order to update the data.

- `ChangeNotifier`: Similar to `InheritedWidget` but used for mutable data such as global state.

## Important widgets

- **Container**: To add padding and margin to children
- **Row**: For horizontal alignment
- **Column**: For vertical alignment
- **ListView**: Scrollable list
- **Stack**: To overlay widgets on top of each other (z axis)
- **Text**
- **Image**
- **Button widgets**: `ElevatedButton`, `TextButton`, `OutlinedButton`
- **TextField**: For text input
- **AppBar**: Top app bar with buttons and navigation
- **Drawer**: App bar's drawer
- **AlertDialog**: Popup dialog
- **BottomSheet**: Popup connected to the bottom for data selection
- **Card**
- **Icon**
- **Spacer**: Flexible space that expands to take up available space
- **AspectRatio**: Enforces aspect ratio of its child, useful for images
- **Divider**: Horizontal line to separate widgets
- **ClipRRect**, **ClipOval**: Widget for clipping children into rounded rectangles and ovals respectively
- **Hero**: For hero animations, where a widget moves smoothly from one screen to another
- **Expanded**: Greedy area, takes up available space
- **Flex**: Displays children in a one dimensional array
- **Flexible**: Used as a direct child of `Row`, `Column` or `Flex`. `Flexible` children occupy space pro-rata according to `flex` factor. Eg if one child has flex 2 and the other has 1, they take space in 2:1 ratio

### Tricks

- If main axis (horizontal or vertical) is known in advance, use `Row` or `Column` instead of `Flex`
- `Flex` does not scroll. Use `ListView` for scrolling
- `Flex` does not wrap. Use `Wrap` for wrapping
- If you only have one child, use `Align` or `Center` instead of `Flex`, `Row` or `Column`
