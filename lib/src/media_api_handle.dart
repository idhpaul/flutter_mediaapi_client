import 'dart:async';

import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaAPI {
  final _authManager = AuthManger();
  final _apiManager = ApiManger();

  void write(String key, dynamic value) async {
    _authManager.write(key, value);
  }

  dynamic read<T>(dynamic key) async {
    _authManager.read<T>(key);
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

  //write token
  void write(String key, dynamic value) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (value is String) {
        await prefs.setString(key, value);
      } else if(value is int){
        await prefs.setInt(key, value);
      } else if(value is double){
        await prefs.setDouble(key, value);
      } else if(value is bool){
        await prefs.setBool(key, value);
      } else if(value is List<String>){
        await prefs.setStringList(key, value);
      } else {
        throw "Not support type";
      }
    } catch (e) {
      logger.e(e);
    }
  }

  //read token
  dynamic read<T>(dynamic key) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    dynamic returnValue;

    try {
      if (T == String) {
        returnValue = prefs.getString(key);
      } else if(T == int){
        returnValue = prefs.getInt(key);
      } else if(T == double){
        returnValue = prefs.getDouble(key);
      } else if(T == bool){
        returnValue = prefs.getBool(key);
      } else if(T == List<String>){
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

  //delete token

  //query token

  //get value from key
}

class ApiManger{

}