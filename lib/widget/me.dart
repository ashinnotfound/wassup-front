import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MeWidget extends StatelessWidget {
  const MeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Text("ayo wassup dude🥳🫵🏼, ${appState.userName}!");
  }
}
