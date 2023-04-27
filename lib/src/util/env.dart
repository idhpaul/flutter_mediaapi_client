import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

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

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    printTime: true // Should each log print contain a timestamp
  ),);


                      
