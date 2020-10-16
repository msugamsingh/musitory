
import 'package:flutter/material.dart';

import 'constants.dart';

class MyAppBar extends StatelessWidget {
  final String title;
  final bool toPop;
  final Function onActionPressed;
  final bool hasAction;
  final IconData actionIcon;
  final GlobalKey<ScaffoldState> scaffoldState;

  MyAppBar({
    Key key,
    this.title,
    this.onActionPressed,
    this.toPop = false,
    this.hasAction = false,
    this.actionIcon = Icons.search,
    this.scaffoldState,
  }) : super(key: key);

  Widget disabledIconButton() {
    return IconButton(icon: Icon(Icons.sort, color: Colors.transparent));
  }

  Widget shadowedIconButton(IconData iconData, BuildContext context,
      Function onTap, [bool action = false]) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness ==
              Brightness.light ? Colors.grey[50] : Colors.blueGrey[700],
          boxShadow: Theme.of(context).brightness ==
              Brightness.light ? [
            BoxShadow(
                color: Colors.grey[400],
                offset: !action ? Offset(8, 8) : Offset(-8, 8),
                blurRadius: 28),
            BoxShadow(
                color: Colors.grey[200],
                offset: !action ? Offset(-8, -8) : Offset(8, -8),
                blurRadius: 10)
          ] : null,
          borderRadius: !action ? BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12))
              : BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12)),
      ),
      child: IconButton(
        icon: Icon(iconData, color: Theme.of(context).brightness ==
            Brightness.light ? Color(0xff151515) : Colors.grey[50],),
        onPressed: onTap,
      ),
    );
  }

  Widget ifToPop(BuildContext context) {
    if (toPop) {
      return shadowedIconButton(Icons.arrow_back_ios, context, () {
        Navigator.pop(context);
      });
    } else if (scaffoldState != null) {
      return shadowedIconButton(CustomIcons.menu, context, () {
        scaffoldState.currentState.openDrawer();
      });
    } else {
      return disabledIconButton();
    }
  }

  Widget action(bool b, BuildContext context) {
    if (b) {
      return shadowedIconButton(actionIcon, context, onActionPressed, true);
    } else {
      return disabledIconButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 70,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ifToPop(context),
            Text(title, textAlign: TextAlign.center, style: appBarStyle),
            action(hasAction, context),
          ],
        ),
      ),
    );
  }
}
