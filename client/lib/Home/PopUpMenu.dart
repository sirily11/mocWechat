import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PopUpMenu extends StatelessWidget {
  final List<String> menuItems;
  final List<Function> actions;

  PopUpMenu(this.menuItems, this.actions);

  select(String value){
    var index = menuItems.indexOf(value);
    actions[index]();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: select,
      itemBuilder: (context) {
        return menuItems.map((item) {
          return PopupMenuItem(value: item, child: Text(item),);
        }).toList();
      },
    );
  }
}