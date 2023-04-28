import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mediaapi_client/src/media_api_handle.dart';
import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:http/http.dart';

class DolbyClient extends StatefulWidget {
  const DolbyClient({Key? key}) : super(key: key);

  @override
  State<DolbyClient> createState() => _DolbyClientState();
}

class _DolbyClientState extends State<DolbyClient> {

  final _mediApi = MediaAPI();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
            child: const Text("Get Auth"),
            onPressed: () async {
              String appkey = ENV['DolbyMediaAPIAppKey']!;
              String appsecret = ENV['DolbyMediaAPIAppSecretKey']!;
              String basicAuth = 'Basic ${base64.encode(utf8.encode('$appkey:$appsecret'))}';
              print(basicAuth);

              // ref : https://docs.dolby.io/media-apis/reference/get-api-token
              //Uri uri = Uri.parse("https://api.dolby.io/v1/auth/token?expires_in=86400");
              Uri uri = Uri.https("api.dolby.io", "/v1/auth/token", {"grant_type":"client_credentials","expires_in":"86400"});
              print(uri);

              Map<String, String> header = {
                'authorization': basicAuth,
                'content-type': "application/x-www-form-urlencoded",
              };

              try {
                final response = await post(
                  uri,
                  headers: header,
                );

                if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

                logger.i(response.statusCode);
                logger.i(response.body);

                var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

                var expireDateTime = HttpDate.parse(response.headers['date']!).add(Duration(seconds: decodedResponse['expires_in']));
                print("토큰 만료일(GST, KST) : ${expireDateTime.millisecondsSinceEpoch}, ${expireDateTime.toLocal()}");
                // var expireTimeStamp = (expireDateTime.millisecondsSinceEpoch + DateTime.now().timeZoneOffset.inMilliseconds); 
                // print(expireTimeStamp);
                
                //logger.d(decodedResponse['token_type']);
                //logger.d(decodedResponse['access_token']);


                _mediApi.write('access_token', decodedResponse['access_token']);
                _mediApi.write('access_token_expire', expireDateTime.millisecondsSinceEpoch);


              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the get 😱/n ${e.message}");
              } catch (e) {
                // executed for errors of all types other than Exception
                logger.e("Couldn't find the get 😱/n ${e}");
              }
            }),
        OutlinedButton(
          child: const Text("Validation access token"),
          onPressed: (){
            var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
            print("현재시간(GST, KST) : $currentTimeStamp, ${(DateTime.fromMillisecondsSinceEpoch(currentTimeStamp).toLocal())}");

            var storeTokenExpireTimeStamp = _mediApi.read<int>('access_token_expire');
            print("토큰시간(GST, KST) : $storeTokenExpireTimeStamp, ${DateTime.fromMillisecondsSinceEpoch(storeTokenExpireTimeStamp).toLocal()}");

            var storeToken = _mediApi.read<String>('access_token');
            print(storeToken);

            if(storeTokenExpireTimeStamp == null)
            {
              print("Need Access Token");
            }

            print((currentTimeStamp > storeTokenExpireTimeStamp ) ? " 만료됨, expired token" : "유효함, valid token");


          },),
        OutlinedButton(
            child: const Text("Get Dolby Temporary Cloud url"),
            onPressed: () async {

              Uri uri = Uri.parse("https://api.dolby.com/media/input");
              Map<String, String> header = {
                'authorization': "Bearer ${_mediApi.read<String>('access_token')}",
                'content-type': "application/json",
              };
              Map<String, String> data = {
                "url": "dlb://sample/test.wav",
              };

              try {
                final response = await post(uri, headers: header, body: json.encode(data));
                

                if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

                logger.i(response.body);

                var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
                _mediApi.write('upload_url', decodedResponse['url']);

                


              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the post 😱 ${e}");
              }
            }),
        ElevatedButton(
            child: const Text("Put wav file to Dolby Temporary Cloud url"),
            onPressed: () async {

              Uri uri = Uri.parse(_mediApi.read<String>('upload_url'));
              ByteData wavData = await rootBundle.load('assets/test/test.wav');

              try {
                final response = await put(uri, body:utf8.encode(wavData.toString()));
                

                if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

                logger.i(response.statusCode);


              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the post 😱 ${e}");
              }
            }),
        ElevatedButton(
            child: const Text("Get wav file to Dolby Temporary Cloud url"),
            onPressed: () async {

              Uri uri = Uri.parse("https://api.dolby.com/media/output");
              Map<String, String> header = {
                'authorization': "Bearer ${_mediApi.read<String>('access_token')}",
                'content-type': "application/json",
              };
              Map<String, String> data = {
                "url": "dlb://sample/test.wav",
              };

              try {
                final response = await post(uri, headers: header, body: json.encode(data));
                

                if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

                logger.i("${response.statusCode} / ${response.body}");

              } on SocketException {
                logger.e('No Internet connection 😑');
              } on HttpException catch (e) {
                logger.e("Couldn't find the post 😱 ${e}");
              }
            }),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
}
