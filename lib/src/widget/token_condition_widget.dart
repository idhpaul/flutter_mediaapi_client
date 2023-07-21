import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mediaapi_client/src/media_api_handle.dart';

class TokenCondition extends StatefulWidget {
  const TokenCondition({
        Key? key, 
    }) : super(key: key);

  @override
  State<TokenCondition> createState() => _TokenConditionState();
}

class _TokenConditionState extends State<TokenCondition> {

  bool check = true;
  IconData stateIcon = Icons.sentiment_very_satisfied;

  @override
  void initState() {
    super.initState();

    _tokenScheduleTimeout(5 * 1000);

  }

  @override
  void dispose() {
    super.dispose();
  }

  Timer _tokenScheduleTimeout([int milliseconds = 10000]) =>
    Timer.periodic(
      Duration(milliseconds: milliseconds), 
      (timer) {
        if(check){
          setState(() {
            stateIcon = Icons.sentiment_very_satisfied;
            //check = false;
          });
        } else {
          setState(() {
            stateIcon = Icons.sentiment_very_dissatisfied;
            check = true;
          });
        }
    });

  @override
  Widget build(BuildContext context) {
    return IconButton(
            icon: Icon(stateIcon),
            onPressed: () {},
            color: const Color(0xff212435),
            iconSize: 24,
            );
  }
}