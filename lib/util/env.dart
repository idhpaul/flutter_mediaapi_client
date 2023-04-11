import 'dart:io';

import 'package:dotenv/dotenv.dart';

// ignore: non_constant_identifier_names
final DotEnv ENV = DotEnv(includePlatformEnvironment: true)..load();
                
// ignore: non_constant_identifier_names
void EnvDefinedCheck() {
  assert(ENV.isEveryDefined([
    'DolbyMediaAPIAppKey',
    'DolbyMediaAPIAppSecretKey',
    ]) ? true : 
    throw "Define Env Value, Check value to command `flutter pub run dotenv` ");
}


                      
