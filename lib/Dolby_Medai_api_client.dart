import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mediaapi_client/util/env.dart';
import 'package:http/http.dart';



class DolbyMedaiApiClient extends StatefulWidget {
  const DolbyMedaiApiClient({ Key? key }) : super(key: key);

  @override
  _DolbyMedaiApiClientState createState() => _DolbyMedaiApiClientState();
}

class _DolbyMedaiApiClientState extends State<DolbyMedaiApiClient> {

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: const Text('Get Auth'),
      onTap: () async {
        String appkey = ENV['DolbyMediaAPIAppKey']!;
        String appsecret = ENV['DolbyMediaAPIAppSecretKey']!;
        String basicAuth = 'Basic ${base64.encode(utf8.encode('$appkey:$appsecret'))}';
        print(basicAuth);

        var url = Uri.parse("https://api.dolby.io/v1/auth/token");
        Response r = await get(
          url,
          headers: <String, String>{'authorization': basicAuth});

        print(r.statusCode);
        print(r.body);
      },
    ); 
  }

  @override
  void dispose() {
    // TODO: implement dispose


    super.dispose();
  }
}