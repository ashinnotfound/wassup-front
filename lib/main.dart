import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wassup_front/widget/me.dart';
import 'widget/home.dart';
import 'widget/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'wassup due🥳🫵🏼',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var token = "";
  var userName = "";
  bool isLoggedIn = false;

  void login(String token, String userName) {
    this.token = token;
    this.userName = userName;
    isLoggedIn = true;
    notifyListeners();
  }

  void updateToken(String token) {
    this.token = token;
  }

  void logout() {
    token = "";
    userName = "";
    isLoggedIn = false;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (!appState.isLoggedIn) {
      return const LoginDialog();
    }

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const Placeholder();
        break;
      case 2:
        page = const MeWidget();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: false,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('首页'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add),
                    label: Text('发送'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.man),
                    label: Text('我'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Center(
                  child: page,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
