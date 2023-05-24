// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedulers/schedulers.dart';
import 'package:http/http.dart';

enum APIReturnType {
  ERROR,

  OK,

  TOKEN_NONE,
  TOKEN_EXPIRE,
  TOKEN_VERIFY,
}

class APIPreferences {
  
  late SharedPreferences prefs;

  void init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void reload(){
    prefs.reload();
  }

  void write(String key, dynamic value) async {
    try {
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        throw "Not support type";
      }
    } catch (e) {
      logger.e(e);
    }
  }

  dynamic read<T>(dynamic key)  {

    dynamic returnValue;

    try {
      if (T == String) {
        returnValue = prefs.getString(key);
      } else if (T == int) {
        returnValue = prefs.getInt(key);
      } else if (T == double) {
        returnValue = prefs.getDouble(key);
      } else if (T == bool) {
        returnValue = prefs.getBool(key);
      } else if (T == List<String>) {
        returnValue = prefs.getStringList(key);
      } else {
        returnValue = null;
        throw "Not support type";
      }

      if (returnValue == null) throw "read null value";
    } catch (e) {
      logger.e(e);
    }

    return returnValue;
  }
}

class APIHandler{
  final _apiPreferences = APIPreferences();
  late DolbyAPIManager _apiManager;
  final intervalScheduler = IntervalScheduler(delay: const Duration(seconds: 1));

  bool hasToken = false;

  APIHandler(){

    _apiPreferences.init();
    _apiManager = DolbyAPIManager(_apiPreferences);

    intervalScheduler.run((){
      hasToken = (APIReturnType.TOKEN_VERIFY == _checkVerifyToken()) ? true : false;

    if (!hasToken) {
      _publishToken();
    }
    });

    _tokenScheduleTimeout(30 * 1000);

  }

  APIPreferences getPreferences(){
    return _apiPreferences;
  }

  Timer _tokenScheduleTimeout([int milliseconds = 10000]) =>
    Timer.periodic(
      Duration(milliseconds: milliseconds), 
      (timer) {
      hasToken = (APIReturnType.TOKEN_VERIFY == _checkVerifyToken()) ? true : false;

      if (!hasToken) {
        _publishToken();
      }
    });


  APIReturnType _checkVerifyToken() {

    _apiPreferences.reload();

    var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;

    var storeTokenExpireTimeStamp = _apiPreferences.read<int>('access_token_expire');
    if(storeTokenExpireTimeStamp == null)
    {
      print("Need Access Token");
      return APIReturnType.TOKEN_NONE;
    }
    print("현재시간(GST, KST) : $currentTimeStamp, ${(DateTime.fromMillisecondsSinceEpoch(currentTimeStamp).toLocal())}");
    print("토큰시간(GST, KST) : $storeTokenExpireTimeStamp, ${DateTime.fromMillisecondsSinceEpoch(storeTokenExpireTimeStamp).toLocal()}");

    print((currentTimeStamp > storeTokenExpireTimeStamp ) ? " 만료됨, expired token" : "유효함, valid token");
    return (currentTimeStamp > storeTokenExpireTimeStamp) ? APIReturnType.TOKEN_EXPIRE: APIReturnType.TOKEN_VERIFY;
   
  }

  void _publishToken() {
    _apiManager._getToken();
  }

  String getAccessToken() {
    var ret = _checkVerifyToken();

    switch (ret) {
      case APIReturnType.TOKEN_NONE:
        _publishToken();
        break;
      case APIReturnType.TOKEN_EXPIRE:
        _publishToken();
        break;
      case APIReturnType.TOKEN_VERIFY:
        break;
      case APIReturnType.ERROR:
        // TODO: Handle this case.
        break;
      case APIReturnType.OK:
        // TODO: Handle this case.
        break;
    }

    return _apiPreferences.read<String>('access_token');
  }
}

class DolbyAPIManager{
  late APIPreferences _apiPreferences;
  
  DolbyAPIManager(APIPreferences apiPreferences){
    _apiPreferences = apiPreferences;
  }

  void _getToken() async {
    String appkey = ENV['DolbyMediaAPIAppKey']!;
    String appsecret = ENV['DolbyMediaAPIAppSecretKey']!;
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$appkey:$appsecret'))}';
    print(basicAuth);

    // ref : https://docs.dolby.io/media-apis/reference/get-api-token
    //Uri uri = Uri.parse("https://api.dolby.io/v1/auth/token?expires_in=86400");
    Uri uri = Uri.https("api.dolby.io", "/v1/auth/token", {"grant_type": "client_credentials", "expires_in": "86400"});
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

      if (response.statusCode != 200)
        throw HttpException('${response.statusCode} / ${response.body}');

      logger.i(response.statusCode);
      logger.i(response.body);

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      var expireDateTime = HttpDate.parse(response.headers['date']!).add(Duration(seconds: decodedResponse['expires_in']));

      print("Token Expire(GST, KST) : ${expireDateTime.millisecondsSinceEpoch}, ${expireDateTime.toLocal()}");

      _apiPreferences.write('access_token', decodedResponse['access_token']);
      _apiPreferences.write('access_token_expire', expireDateTime.millisecondsSinceEpoch);


    } on SocketException {
      logger.e('No Internet connection 😑');
    } on HttpException catch (e) {
      logger.e("Couldn't find the get 😱/n ${e.message}");
    } catch (e) {
      // executed for errors of all types other than Exception
      logger.e("Couldn't find the get 😱/n ${e}");
    }
  }
}
