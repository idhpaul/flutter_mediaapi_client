import 'dart:async';

import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaAPI {
  final _authManager = AuthManger()..init();
  final _apiManager = ApiManger();

  void write(String key, dynamic value) async {
    _authManager.write(key, value);
  }

  dynamic read<T>(dynamic key) {
    return _authManager.read<T>(key);
  }
}

class AuthManger{

  //Storage location by platform 
  //[Android]	      SharedPreferences
  //[iOS]           NSUserDefaults
  //[Linux]         In the XDG_DATA_HOME directory
  //[macOS]	        NSUserDefaults
  //[Web]	          LocalStorage
  //[Windows]	      In the roaming AppData directory

  late SharedPreferences _prefs;

  Future init() async =>
      _prefs = await SharedPreferences.getInstance();

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

  //get value from key
}

class ApiManger{

}