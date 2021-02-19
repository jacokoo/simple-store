import 'package:example/module/home/home.dart';
import 'package:flutter/material.dart';
import 'package:simple_store/simple_store.dart';

void main() {
    runApp(SimpleStoreApp(
        home: MyApp(),
        builder: (delegate, parser) => MaterialApp.router(
            routeInformationParser: parser, routerDelegate: delegate
        ),
    ));
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Column(children: [
            Expanded(child: HomeModule()),
            Center(child: Text('hello world', style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal
            )))
        ]);
    }
}
