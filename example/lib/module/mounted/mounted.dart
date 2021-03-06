import 'package:example/module/mounted/by_build_method/module.dart';
import 'package:example/module/mounted/by_default_page/module.dart';
import 'package:flutter/material.dart';

class MountedWidget extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Mounted Module')),
            backgroundColor: Colors.grey.shade200,
            body: SafeArea(child: Column(children: [
                titleWidget('In MountedByBuildMethod module'),
                contentWidget(MountedByBuildMethodModule()),
                titleWidget('In MountedByDefaultPage module'),
                contentWidget(MountedByDefaultPageModule()),
            ])),
        );
    }

    Widget titleWidget(String title) {
        return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14, 12, 0, 8),
            child: Text(title, style: TextStyle(color: Colors.grey)),
        );
    }

    Widget contentWidget(Widget child) {
        return Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: child,
        );
    }
}
