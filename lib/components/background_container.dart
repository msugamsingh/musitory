import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final IconData expandedIcon;

  BackgroundContainer({this.expandedIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness ==
              Brightness.light ? LinearGradient(
            colors: [
              Colors.grey[50],
              Colors.grey[200],
//                  Colors.pink,
//                    Colors.purple
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ) : null,
          color: Theme.of(context).brightness ==
              Brightness.light ? null : Colors.blueGrey[900],
        ),
        child: expandedIcon != null
            ? Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                  ),
                  Expanded(
                      child: Container(
                          child: Icon(expandedIcon,
                              size: MediaQuery.of(context).size.width-40,
                              color: Theme.of(context).brightness ==
                                  Brightness.light ? Colors.grey[300] : Colors.blueGrey[700],))),
                ],
              )
            : null);
  }
}
