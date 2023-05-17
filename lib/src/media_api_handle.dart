// ignore_for_file: constant_identifier_names

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

class MediaAPI {
  final _apiManager = ApiManger();
  final _tokenManager = TokenManager()..init();
  final _tokenBagroundService = IntervalScheduler(delay: const Duration(seconds: 10)); 
  bool hasToken = false;

  void write(String key, dynamic value) async {
    _tokenManager.write(key, value);
  }

  dynamic read<T>(dynamic key) {
    return _tokenManager.read<T>(key);
  }

  void registerTokenBackgroundService(){
    _tokenBagroundService.run(() => _callbackTokenBackgroundService());
  }

  void _callbackTokenBackgroundService(){
    // check token
    hasToken = (APIReturnType.TOKEN_VERIFY ==_checkToken()) ? true : false;
    
  }


  APIReturnType _checkToken() {
    return _tokenManager.checkVerifyToken();
  }

  void _publishToken() {
    var retJson = _apiManager.getToken();

    //write('access_token', retJson['access_token']);
    //write('access_token_expire', expireDateTime.millisecondsSinceEpoch);
  }

  String _getToken() {
    return read<String>('access_token');
  }

  String  getToken() {
    var ret = _tokenManager.checkVerifyToken();
    
    // switch (ret) {
    //   case APIReturnType.TOKEN_NONE:
    //     _publishToken();
    //     break;
    //   case APIReturnType.TOKEN_EXPIRE:
    //     _publishToken();
    //     break;
    //   case APIReturnType.TOKEN_VERIFY:
    //     break;
    // }

    return _getToken();
    
  }

}

class TokenManager{

  //Storage location by platform 
  //[Android]	      SharedPreferences
  //[iOS]           NSUserDefaults
  //[Linux]         In the XDG_DATA_HOME directory
  //[macOS]	        NSUserDefaults
  //[Web]	          LocalStorage
  //[Windows]	      In the roaming AppData directory

  late SharedPreferences _prefs;
  bool _hasToken = false;

  Future init() async {
      _prefs = await SharedPreferences.getInstance();
      _hasToken = (APIReturnType.TOKEN_VERIFY==checkVerifyToken()) ? true : false;
  }
  //write token
  void write(String key, dynamic value) async {

    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if(value is int){
        await _prefs.setInt(key, value);
      } else if(value is double){
        await _prefs.setDouble(key, value);
      } else if(value is bool){
        await _prefs.setBool(key, value);
      } else if(value is List<String>){
        await _prefs.setStringList(key, value);
      } else {
        throw "Not support type";
      }
    } catch (e) {
      logger.e(e);
    }
  }

  //read token
  dynamic read<T>(dynamic key) {

    dynamic returnValue;

    try {
      if (T == String) {
        returnValue = _prefs.getString(key);
      } else if(T == int){
        returnValue = _prefs.getInt(key);
      } else if(T == double){
        returnValue = _prefs.getDouble(key);
      } else if(T == bool){
        returnValue = _prefs.getBool(key);
      } else if(T == List<String>){
        returnValue = _prefs.getStringList(key);
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

  //delete token

  //query token

  //get token
  void getToken(){
    var storeToken = read<String>('access_token');
    print(storeToken);
  }

  void publishToken() {

  }

  //init verify access token
  APIReturnType checkVerifyToken() {
    var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    print("Current Timestamp(GST, KST) : $currentTimeStamp, ${(DateTime.fromMillisecondsSinceEpoch(currentTimeStamp).toLocal())}");

    try {
      var storeTokenExpireTimeStamp = read<int>('access_token_expire');
      if(storeTokenExpireTimeStamp == null){
        return APIReturnType.TOKEN_NONE;
      } else {
        print("Current Token Timestamp(GST, KST) : $storeTokenExpireTimeStamp, ${DateTime.fromMillisecondsSinceEpoch(storeTokenExpireTimeStamp).toLocal()}");
      }

      return (currentTimeStamp > storeTokenExpireTimeStamp ) ? APIReturnType.TOKEN_EXPIRE : APIReturnType.TOKEN_VERIFY;

    } catch (e) {
      print(e);
      return APIReturnType.ERROR;
    }
    
  }
}

class ApiManger{

  void getToken() async {
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

      decodedResponse.addEntries({'access_token_expire': '$expireDateTime'} as Iterable<MapEntry>);
      print("Token Expire(GST, KST) : ${expireDateTime.millisecondsSinceEpoch}, ${expireDateTime.toLocal()}");

      // var expireTimeStamp = (expireDateTime.millisecondsSinceEpoch + DateTime.now().timeZoneOffset.inMilliseconds); 
      // print(expireTimeStamp);

      //logger.d(decodedResponse['token_type']);
      //logger.d(decodedResponse['access_token']);

      return decodedResponse;

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