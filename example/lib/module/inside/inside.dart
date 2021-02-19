import 'package:example/module/inside/bar.dart';
import 'package:example/module/inside/foo.dart';
import 'package:flutter/material.dart';

class InsideWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Mounted Module')),
            body: SafeArea(child: Column(children: [
                Container(
                    child: Column(children: [
                        Text('In Module Foo'),
                        FooModule(),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    color: Colors.purple.shade100,
                    padding: EdgeInsets.all(20),
                ),
                Container(
                    child: Column(children: [
                        Text('In Module Bar'),
                        BarModule(),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    color: Colors.yellow.shade200,
                    padding: EdgeInsets.all(20),
                ),
            ])),
        );
    }
}
