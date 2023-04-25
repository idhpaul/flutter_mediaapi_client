import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mediaapi_client/util/env.dart';
import 'package:http/http.dart';

class DolbyMedaiApiClient extends StatefulWidget {
  const DolbyMedaiApiClient({Key? key}) : super(key: key);

  @override
  State<DolbyMedaiApiClient> createState() => _DolbyMedaiApiClientState();
}

class _DolbyMedaiApiClientState extends State<DolbyMedaiApiClient> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
            child: const Text("Get Auth"),
            onPressed: () async {
              String appkey = ENV['DolbyMediaAPIAppKey']!;
              String appsecret = ENV['DolbyMediaAPIAppSecretKey']!;
              String basicAuth =
                  'Basic ${base64.encode(utf8.encode('$appkey:$appsecret'))}';
              print(basicAuth);

              // ref : https://docs.dolby.io/media-apis/reference/get-api-token
              Uri uri = Uri.parse("https://api.dolby.io/v1/auth/token");

              Map<String, String> header = {
                'Authorization': basicAuth,
              };

              try {
                final response = await get(
                  uri,
                  headers: header,
                );

                if (response.statusCode != 200)throw HttpException('${response.statusCode}/${response.body}');

                logger.i(response.statusCode);
                logger.i(response.body);

                var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
                //logger.d(decodedResponse['token_type']);
                //logger.d(decodedResponse['access_token']);

              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the get 😱/n ${e.message}");
              }
            }),
        OutlinedButton(
            child: const Text("Get Dolby Temporary Cloud url"),
            onPressed: () async {
              String appkey = ENV['DolbyMediaAPIAppKey']!;
              String appsecret = ENV['DolbyMediaAPIAppSecretKey']!;
              String basicAuth = 'Basic ${base64.encode(utf8.encode('$appkey:$appsecret'))}';
              print(basicAuth);

              Uri uri = Uri.parse("https://api.dolby.com/media/input");
              Map<String, String> header = {
                'authorization': basicAuth,
              };
              Map<String, String> data = {'url': 'dlb://example/test.wav'};

              try {
                final response = await post(uri, headers: header, body: data);

                if (response.statusCode != 200) throw HttpException('${response.statusCode}/${response.body}');

                logger.i(response.statusCode);
                logger.i(response.body);

                var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
                logger.d(decodedResponse['token_type']);
                logger.d(decodedResponse['access_token']);
              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the get 😱/n ${e.message}");
              }
            }),
        ElevatedButton(
            child: const Text("Upload File at Dolby Temporary Cloud"),
            onPressed: () {}),
        ElevatedButton(
            child: const Text("Download File at Dolby Temporary Cloud"),
            onPressed: () {}),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
}
