import 'package:flutter/material.dart';

class MountedByDefaultPageDetailPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Detail Page')),
            body: Center(child: Text('Detail page for mounted by default page module'),),
        );
    }
}
