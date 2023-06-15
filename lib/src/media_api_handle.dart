// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart';
import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedulers/schedulers.dart';
import 'package:http/http.dart';

const int TIMER_PERIODIC_MS = 1000;


enum APIReturnType {
  ERROR,

  OK,

  TOKEN_NONE,
  TOKEN_EXPIRE,
  TOKEN_VERIFY,
}

class APIPreferences {
  
  late SharedPreferences prefs;
  late Excel excel;
  late Sheet sheet;

  void init() async {
    prefs = await SharedPreferences.getInstance();
    excel = Excel.createExcel();
    sheet = excel['Enhance Result'];

    var headCell1 = sheet.cell(CellIndex.indexByString("A3"));
    headCell1.value = "index";

    var headCell2 = sheet.cell(CellIndex.indexByString("B3"));
    headCell2.value = "Start Enhance";

    var headCell3 = sheet.cell(CellIndex.indexByString("C3"));
    headCell3.value = "End Enhance";

    var headCell4 = sheet.cell(CellIndex.indexByString("D3"));
    headCell4.value = "Run Time";

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

  void write_excel(String cellIdx, dynamic data){
    var cell = sheet.cell(CellIndex.indexByString(cellIdx));
    cell.value = data;
  }

  void save_excel(){
    print('Current path style: ${p.style}');

    print('Current process path: ${p.current}');

    print('Separators');
    for (var entry in [p.posix, p.windows, p.url]) {
      print('  ${entry.style.toString().padRight(7)}: ${entry.separator}');
    }

    String outputFile = "/Users/idhpaul/Desktop/output.xlsx";

    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File(p.join(outputFile))
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }


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
    // 외부에서 값을 수정했을 경우 캐쉬에 반영되지 않음(직접적으로 파일 내용 수정 및 삭제 등 포함)
    // Shared_preference Method를 사용한 경우에만 캐쉬 작동
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

    print((currentTimeStamp > storeTokenExpireTimeStamp ) ? " 토큰 만료" : "토큰 유효");
    return (currentTimeStamp > storeTokenExpireTimeStamp) ? APIReturnType.TOKEN_EXPIRE: APIReturnType.TOKEN_VERIFY;
   
  }

  void _publishToken() {
    _apiManager._getToken();
  }

  void getTokenState() {
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

  }

  Future<String> createPreSignEnhance(int inputNum) async {
    return _apiManager._createPreSignEnhance(inputNum);
  }

  Future<String> createPreSignAnalyze(int inputNum) async {
    return _apiManager._createPreSignAnalyze(inputNum);
  }

  Future<String> createPreSignEqualize(int inputNum) async {
    return _apiManager._createPreSignEqualize(inputNum);
  }

  Future<String> getAnalyzeJson(int idx, {int retryCount = 0}) async {
    return _apiManager._getAnalyzeJson(idx);
  }

  void startEnhancing(int idx, String urlsJson){
    _apiManager._startEnhancing(idx, urlsJson);
  }

  void startAnalyze(int idx, String urlsJson){
    _apiManager._startAnalyzing(idx, urlsJson, isOriginal:true);
    _apiManager._startAnalyzing(idx, urlsJson);
  }

  void compareAnalyzeData(int idx, String urlsJson){
    _apiManager._compareAnalyzeData(idx, urlsJson);
  }

  void startEqualize(int idx, String urlsJson){
    _apiManager._startEqualizing(idx, urlsJson);
  }

  void saveData(){
    // 시간 계산 : =TEXT(C4-B4,"mm:ss.000")
    _apiPreferences.save_excel();

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

  Future<String> _createPreSignEnhance(int inputNum) async {

    Uri uri = Uri.parse("http://localhost:8080/presignEnhance");
    Map<String, String> header = {
      'content-type': "application/json",
    };
    Map<String, dynamic> data = {
      "count": inputNum,
    };

    late Response response;

    try {

      response = await post(uri, headers: header ,body:jsonEncode(data));

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  Future<String> _createPreSignAnalyze(int inputNum, {int retryCount = 0}) async {

    Uri uri = Uri.parse("http://localhost:8080/presignAnalyze");
    Map<String, String> header = {
      'content-type': "application/json",
    };
    Map<String, dynamic> data = {
      "count": inputNum,
      "retry": retryCount
    };

    late Response response;

    try {

      response = await post(uri, headers: header ,body:jsonEncode(data));

      if (response.statusCode != 200) throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  Future<String> _createPreSignEqualize(int inputNum, {int retryCount = 0}) async {

    Uri uri = Uri.parse("http://localhost:8080/presignEqualize");
    Map<String, String> header = {
      'content-type': "application/json",
    };
    Map<String, dynamic> data = {
      "count": inputNum,
      "retry": retryCount
    };

    late Response response;

    try {

      response = await post(uri, headers: header ,body:jsonEncode(data));

      if (response.statusCode != 200) throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  Future<String> _getAnalyzeJson(int idx, {int retryCount = 0}) async {

    Uri uri = Uri.parse("http://localhost:8080/getAnalyzeJson");
    Map<String, String> header = {
      'content-type': "application/json",
    };
    Map<String, dynamic> data = {
      "index": idx,
      "retry": retryCount
    };

    late Response response;

    try {

      response = await post(uri, headers: header ,body:jsonEncode(data));

      if (response.statusCode != 200) throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  void _startEnhancing(int idx, String urlsJson) async {

    String basicAuth = "Bearer ${_apiPreferences.read<String>('access_token')}";
    //print(basicAuth);

    var decodedUrlJson = jsonDecode(urlsJson);
    //print(decodedUrlJson['urls'][idx]['input']);
    //print(decodedUrlJson['urls'][idx]['output']);

    Uri uri = Uri.parse("https://api.dolby.com/media/enhance");
    Map<String, String> header = {
      'authorization': basicAuth,
      'content-type': "application/json",
    };
    Map<String, dynamic> data = {
      "audio": {"noise": {"reduction": {"enable": true}}},
      "content":{"type": "voice_over"},
      "input": decodedUrlJson['urls'][idx]['input'],
      "output": decodedUrlJson['urls'][idx]['output']
    };

    try {

      final response = await post(uri, headers: header ,body:jsonEncode(data));
      

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");
      logger.i("$idx - Enhancing Start");

      var selidx1 = "A${idx+4}";
      _apiPreferences.write_excel(selidx1,idx+1);
      var selidx2 = "B${idx+4}";

      _apiPreferences.write_excel(selidx2,DateTime.now().toLocal().toString());

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      _apiPreferences.write('enhance_job_id_$idx', decodedResponse['job_id']);

      Timer.periodic(
      const Duration(milliseconds: TIMER_PERIODIC_MS), 
      (timer) {

        var res = _checkEnhancingStatus(idx);
        res.then((val) {
          var decodedUrlJson = jsonDecode(val);
          print(decodedUrlJson['status']);

          if(decodedUrlJson['status'] == 'Success'){
            logger.i("$idx - Enhancing End");

            var selidx1 = "C${idx+4}";
            _apiPreferences.write_excel(selidx1,DateTime.now().toLocal().toString());

            timer.cancel();
          }
          else{
            String doingMsg = "Running ${idx} : ${decodedUrlJson['progress']}";
            logger.e(doingMsg);
          }

        }).catchError((error) {
          // error가 해당 에러를 출력
          print('error: $error');
        });

    });
      
    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }
  }

  Future<String> _checkEnhancingStatus(int idx) async {
    Uri uri = Uri.https("api.dolby.com", "/media/enhance", {"job_id":_apiPreferences.read<String>('enhance_job_id_$idx')});
    //print(uri);

    Map<String, String> header = {
      'authorization': "Bearer ${_apiPreferences.read<String>('access_token')}",
      'content-type': "application/json",
    };

    late Response response;

    try {
      response = await get(uri, headers: header);

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  void _startAnalyzing(int idx, String urlsJson, {bool isOriginal = false} ) async {

    String basicAuth = "Bearer ${_apiPreferences.read<String>('access_token')}";
    //print(basicAuth);

    var decodedUrlJson = jsonDecode(urlsJson);
    //print(decodedUrlJson['urls'][idx]['input']);
    //print(decodedUrlJson['urls'][idx]['output']);

    Uri uri = Uri.parse("https://api.dolby.com/media/analyze");
    Map<String, String> header = {
      'authorization': basicAuth,
      'content-type': "application/json",
    };
    
    Map<String, dynamic> data = 
    (isOriginal) 
    ? {
        "content":{"silence":{"threshold":-60,"duration":2}},
        "input": decodedUrlJson['urljsons'][idx]['originalurl'],
        "output": decodedUrlJson['urljsons'][idx]['originalouputjson']
      }
    : {
        "content":{"silence":{"threshold":-60,"duration":2}},
        "input": decodedUrlJson['urljsons'][idx]['inputurl'],
        "output": decodedUrlJson['urljsons'][idx]['outputjson']
    };

    try {

      final response = await post(uri, headers: header ,body:jsonEncode(data));
      

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");
      logger.i("$idx - Analyzing Start");

      // var selidx1 = "A${idx+4}";
      // _apiPreferences.write_excel(selidx1,idx+1);
      // var selidx2 = "B${idx+4}";

      // _apiPreferences.write_excel(selidx2,DateTime.now().toLocal().toString());

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      (isOriginal) ? _apiPreferences.write('analyze_original_job_id_$idx', decodedResponse['job_id']) 
                    : _apiPreferences.write('analyze_job_id_$idx', decodedResponse['job_id']);
      
      

      Timer.periodic(
      const Duration(milliseconds: TIMER_PERIODIC_MS), 
      (timer) {

        var res = (isOriginal) ? _checkAnalyzeStatus(idx,isOriginal: true) : _checkAnalyzeStatus(idx);
        res.then((val) {
          var decodedUrlJson = jsonDecode(val);
          print(decodedUrlJson['status']);

          if(decodedUrlJson['status'] == 'Success'){
            logger.i("$idx - Analyzing End");

            //var selidx1 = "C${idx+4}";
           // _apiPreferences.write_excel(selidx1,DateTime.now().toLocal().toString());

            timer.cancel();
          }
          else{
            String doingMsg = "Running ${idx} : ${decodedUrlJson['progress']}";
            logger.e(doingMsg);
          }

        }).catchError((error) {
          // error가 해당 에러를 출력
          print('error: $error');
        });

    });
      
    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }
  }

  Future<String> _checkAnalyzeStatus(int idx,{bool isOriginal = false}) async {

    Uri uri;
    if(isOriginal){
      uri = Uri.https("api.dolby.com", "/media/analyze", {"job_id":_apiPreferences.read<String>('analyze_original_job_id_$idx')});
    }
    else{
      uri = Uri.https("api.dolby.com", "/media/analyze", {"job_id":_apiPreferences.read<String>('analyze_job_id_$idx')});
    }
    //print(uri);

    Map<String, String> header = {
      'authorization': "Bearer ${_apiPreferences.read<String>('access_token')}",
      'content-type': "application/json",
    };


    late Response response;

    try {
      response = await get(uri, headers: header);

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

  void _compareAnalyzeData(int idx, String urlsJson, {bool isOriginal = false} ) async {

    var decodedUrlJson = jsonDecode(urlsJson);
    //print(decodedUrlJson['originalAnalyzejson']);
    //print(decodedUrlJson['analyzejson']);

    Uri originalJsonUri = Uri.parse(decodedUrlJson['originalAnalyzejson']);
    Uri outputJsonUri = Uri.parse(decodedUrlJson['analyzejson']);
    Map<String, String> header = {
      'content-type': "application/json",
    };

    double originalAnalyzeNoiseAverage;
    double analyzeNoiseAverage;
    
    try {

      final response = await get(originalJsonUri);
      

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / Get Original Analyze Json Data");

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      originalAnalyzeNoiseAverage = decodedResponse['processed_region']['audio']['noise']['level_average'];

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    try {

      final response = await get(outputJsonUri, headers: header);
      

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / Get Analyze Json Data");

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      analyzeNoiseAverage = decodedResponse['processed_region']['audio']['noise']['level_average'];

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    var diffNoise = originalAnalyzeNoiseAverage.abs() - analyzeNoiseAverage.abs();
    logger.i("$diffNoise");

  }

  void _startEqualizing(int idx, String urlsJson, {bool isOriginal = false} ) async {

    String basicAuth = "Bearer ${_apiPreferences.read<String>('access_token')}";
    //print(basicAuth);

    var decodedUrlJson = jsonDecode(urlsJson);
    //print(decodedUrlJson['urls'][idx]['input']);
    //print(decodedUrlJson['urls'][idx]['output']);

  
    Uri uri = Uri.parse("https://api.dolby.com/media/enhance");
    Map<String, String> header = {
      'authorization': basicAuth,
      'content-type': "application/json",
    };
    
    Map<String, dynamic> data = 
    (isOriginal) 
    ? {
        "audio":{
                  "loudness": { "enable": false },
                  "dynamics": { "range_control": { "enable": false } },
                  "filter": { "high_pass": { "enable": false } },
                  "noise": { "reduction": { "enable": true } },
                  "speech": {
                    "sibilance": { "reduction": { "enable": false } },
                    "isolation": { "enable": true, "amount": 100 }
                  }
                },
        "input": decodedUrlJson['urls'][idx]['originalinput'],
        "output": decodedUrlJson['urls'][idx]['originalouput']
      }
    : {
        "audio":{
                  "loudness": { "enable": false },
                  "dynamics": { "range_control": { "enable": false } },
                  "filter": { "high_pass": { "enable": false } },
                  "noise": { "reduction": { "enable": true } },
                  "speech": {
                    "sibilance": { "reduction": { "enable": false } },
                    "isolation": { "enable": true, "amount": 100 }
                  }
                },
        "input": decodedUrlJson['urls'][idx]['input'],
        "output": decodedUrlJson['urls'][idx]['output']
    };

    try {

      final response = await post(uri, headers: header ,body:jsonEncode(data));
      

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");
      logger.i("$idx - Equalizing Start");

      // var selidx1 = "A${idx+4}";
      // _apiPreferences.write_excel(selidx1,idx+1);
      // var selidx2 = "B${idx+4}";

      // _apiPreferences.write_excel(selidx2,DateTime.now().toLocal().toString());

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      (isOriginal) ? _apiPreferences.write('equalize_original_job_id_$idx', decodedResponse['job_id']) 
                    : _apiPreferences.write('equalize_job_id_$idx', decodedResponse['job_id']);
      
      

      Timer.periodic(
      const Duration(milliseconds: TIMER_PERIODIC_MS), 
      (timer) {

        var res = (isOriginal) ? _checkEqualizeStatus(idx,isOriginal: true) : _checkEqualizeStatus(idx);
        res.then((val) {
          var decodedUrlJson = jsonDecode(val);
          print(decodedUrlJson['status']);

          if(decodedUrlJson['status'] == 'Success'){
            logger.i("$idx - Equalizing End");

            //var selidx1 = "C${idx+4}";
            //_apiPreferences.write_excel(selidx1,DateTime.now().toLocal().toString());

            timer.cancel();
          }
          else{
            String doingMsg = "Running ${idx} : ${decodedUrlJson['progress']}";
            logger.e(doingMsg);
          }

        }).catchError((error) {
          // error가 해당 에러를 출력
          print('error: $error');
        });

    });
      
    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }
  }

  Future<String> _checkEqualizeStatus(int idx,{bool isOriginal = false}) async {

    Uri uri;
    if(isOriginal){
      uri = Uri.https("api.dolby.com", "/media/enhance", {"job_id":_apiPreferences.read<String>('equalize_original_job_id_$idx')});
    }
    else{
      uri = Uri.https("api.dolby.com", "/media/enhance", {"job_id":_apiPreferences.read<String>('equalize_job_id_$idx')});
    }
    //print(uri);

    Map<String, String> header = {
      'authorization': "Bearer ${_apiPreferences.read<String>('access_token')}",
      'content-type': "application/json",
    };


    late Response response;

    try {
      response = await get(uri, headers: header);

      if (response.statusCode != 200)throw HttpException('${response.statusCode} / ${response.body}');

      logger.i("${response.statusCode} / ${response.body}");

    } on SocketException {
      String errMsg = "No Internet connection 😑";
      logger.e(errMsg);
      throw SocketException(errMsg);
    } on HttpException catch (e) {
      String errMsg = "Couldn't find the post 😱 ${e}";
      logger.e(errMsg);
      throw HttpException(errMsg);
    }

    return response.body;
  }

}
