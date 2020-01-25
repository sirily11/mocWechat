import 'dart:io';

import 'package:flutter/material.dart';

double kTabletWidth = 768;
double kMasterWidth = 300;

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0 || Platform.isMacOS;
}

/// This widget will build widget accoding to the
/// size of the screen
class MasterDetailContainer extends StatelessWidget {
  /// Master widget
  final Widget child;

  MasterDetailContainer({@required this.child});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: isTablet(context) ? kMasterWidth : width,
            child: child,
          )
        ],
      ),
    );
  }
}
