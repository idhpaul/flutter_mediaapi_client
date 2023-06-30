import 'dart:async';

import 'package:async_button_builder/async_button_builder.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_mediaapi_client/src/media_api_handle.dart';
import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:flutter_mediaapi_client/src/widget/token_condition_widget.dart';

final stopwatch = Stopwatch();
int gLoadTime = 0;

void main() async {
  stopwatch.start();

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  EnvDefinedCheck();

  runApp(const MyApp());
}

class BottomNavigationBarModel {
  IconData icon;
  String label;

  BottomNavigationBarModel({required this.icon, required this.label});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BottomNavigationBarModel> bottomNavigationBarItems = [
    BottomNavigationBarModel(icon: Icons.home, label: "Home"),
    BottomNavigationBarModel(icon: Icons.account_circle, label: "Account")
  ];

  final apiHandler = APIHandler();
  final enhanceTextFieldController = TextEditingController();
  final analyzeTextFieldController = TextEditingController();

  int lastMiliSecondTime = 0;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    // onChange: (value) {
    //   print('onChange $value');
    // },
    // onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    // onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
    // onStopped: () {
    //   print('onStop');
    // },
    // onEnded: () {
    //   print('onEnded');
    // },
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      stopwatch.stop();
      setState(() {
        gLoadTime = stopwatch.elapsedMilliseconds;
      });
    });

    // _stopWatchTimer.rawTime.listen((value) => print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    // _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    // _stopWatchTimer.records.listen((value) => print('records $value'));
    // _stopWatchTimer.fetchStopped.listen((value) => print('stopped from stream'));
    // _stopWatchTimer.fetchEnded.listen((value) => print('ended from stream'));
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          elevation: 4,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xff3a57e8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            "AppBar",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              color: Color(0xff000000),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: bottomNavigationBarItems.map((BottomNavigationBarModel item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
          backgroundColor: const Color(0xffffffff),
          currentIndex: 0,
          elevation: 8,
          iconSize: 24,
          selectedItemColor: const Color(0xff3a57e8),
          unselectedItemColor: const Color(0xff9e9e9e),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (value) {},
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "구동시간 : $gLoadTime ms",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                  const VerticalDivider(
                    color: Color(0xff808080),
                    width: 16,
                    thickness: 0,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const Text(
                    "토큰 상태",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                  const TokenCondition(),
                ],
              ),
              const Divider(
                color: Color(0xff808080),
                height: 16,
                thickness: 0,
                indent: 0,
                endIndent: 0,
              ),

              // 노이즈캔슬링 처리
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0x1f000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "노이즈캔슬링 처리시간",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 20,
                                color: Color(0xff000000),
                              ),
                            ),
                            TextField(
                              controller: enhanceTextFieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                hintText: "시료 수 입력(1~100)",
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xfff2f2f3),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: AsyncButtonBuilder(
                            onPressed: () async {
                              if (enhanceTextFieldController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // 바깥 영역 터치시 닫을지 여부
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('에러'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text('값을 입력하세요'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                                throw 'Data empty';
                              } else {
                                int inputNum =
                                    int.parse(enhanceTextFieldController.text);

                                lastMiliSecondTime = 0;
                                _stopWatchTimer.onStartTimer();

                                if (0 < inputNum && inputNum <= 10) {
                                  print('노이즈캔슬링 시작');

                                  // #1 request job
                                  var res =
                                      apiHandler.createPreSignEnhance(inputNum);
                                  res.then((val) {
                                    print('주소 생성 완료');
                                    // 2 노이즈캔슬링 시작 (순차형, 분산형 방법 미정)
                                    // param - 생성된 링크 배열
                                    // return - 노이즈 캔슬링 jobid or void
                                    for (var idx = 0; idx < inputNum; idx++) {
                                      apiHandler.startEnhancing(idx, val);
                                    }
                                  }).catchError((error) async {
                                    // error가 해당 에러를 출력
                                    print('error: $error');
                                    throw 'error';
                                  });

                                  // #2 wait job is done and stop timer
                                  await Future.delayed(
                                      const Duration(seconds: 30), () {
                                    setState(() {
                                      _stopWatchTimer.onStopTimer();
                                      _stopWatchTimer.onResetTimer();
                                    });
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible:
                                          true, // 바깥 영역 터치시 닫을지 여부
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('에러'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text('범위내의 값을 입력하세요. (1~100)'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('확인'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  throw 'Out of Data range';
                                }
                              }
                            },
                            loadingWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: _stopWatchTimer.rawTime.value,
                                  builder: (context, snap) {
                                    final value = snap.data!;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value,
                                            hours: false);
                                    lastMiliSecondTime = value;
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            displayTime,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            builder: (context, child, callback, buttonState) {
                              final buttonColor = buttonState.when(
                                idle: () => Colors.blue,
                                loading: () => Colors.green,
                                success: () => Colors.orangeAccent,
                                error: (_, __) => Colors.orange,
                              );

                              return OutlinedButton(
                                onPressed: callback,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: buttonColor,
                                ),
                                child: child,
                              );
                            },
                            child:
                                Text('Run Noise  < $lastMiliSecondTime ms >'),
                          )),
                    ),
                  ],
                ),
              ),

              // 노이즈캔슬링 평가
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0x1f000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "노이즈캔슬링 평가",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 20,
                                color: Color(0xff000000),
                              ),
                            ),
                            TextField(
                              controller: enhanceTextFieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                hintText: "시료 수 입력(1~100)",
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xfff2f2f3),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: AsyncButtonBuilder(
                            onPressed: () async {
                              if (enhanceTextFieldController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // 바깥 영역 터치시 닫을지 여부
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('에러'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text('값을 입력하세요'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                                throw 'Data empty';
                              } else {
                                int inputNum =
                                    int.parse(enhanceTextFieldController.text);

                                lastMiliSecondTime = 0;
                                _stopWatchTimer.onStartTimer();

                                if (0 < inputNum && inputNum <= 10) {
                                  print('노이즈캔슬링 평가 시작');

                                  // #1 request job
                                  var res =
                                      apiHandler.createPreSignAnalyze(inputNum);
                                  res.then((val) {
                                    print('주소 생성 완료');
                                    // 2 음성 분석 시작 (순차형, 분산형 방법 미정)
                                    for (var idx = 0; idx < inputNum; idx++) {
                                      apiHandler.startAnalyze(idx, val);
                                    }
                                  }).catchError((error) async {
                                    // error가 해당 에러를 출력
                                    print('error: $error');
                                    throw 'error';
                                  });

                                  // #2 wait job is done and stop timer
                                  await Future.delayed(
                                      const Duration(seconds: 30), () {
                                    for (var idx = 0; idx < inputNum; idx++) {
                                      var res = apiHandler.getAnalyzeJson(idx);
                                      res.then((val) {
                                        apiHandler.compareAnalyzeData(idx, val);
                                      }).catchError((error) {
                                        // error가 해당 에러를 출력
                                        print('error: $error');
                                        throw 'error';
                                      });
                                    }

                                    setState(() {
                                      _stopWatchTimer.onStopTimer();
                                      _stopWatchTimer.onResetTimer();
                                    });
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible:
                                          true, // 바깥 영역 터치시 닫을지 여부
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('에러'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text('범위내의 값을 입력하세요. (1~100)'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('확인'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  throw 'Out of Data range';
                                }
                              }
                            },
                            loadingWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: _stopWatchTimer.rawTime.value,
                                  builder: (context, snap) {
                                    final value = snap.data!;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value,
                                            hours: false);
                                    lastMiliSecondTime = value;
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            displayTime,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            builder: (context, child, callback, buttonState) {
                              final buttonColor = buttonState.when(
                                idle: () => Colors.blue,
                                loading: () => Colors.green,
                                success: () => Colors.orangeAccent,
                                error: (_, __) => Colors.orange,
                              );

                              return OutlinedButton(
                                onPressed: callback,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: buttonColor,
                                ),
                                child: child,
                              );
                            },
                            child:
                                Text('Run Noise  < $lastMiliSecondTime ms >'),
                          )),
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Color(0xff808080),
                height: 16,
                thickness: 0,
                indent: 0,
                endIndent: 0,
              ),

              // 이퀄라이징 처리
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0x1f000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "이퀄라이징 처리 시간",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 20,
                                color: Color(0xff000000),
                              ),
                            ),
                            TextField(
                              controller: enhanceTextFieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                hintText: "시료 수 입력(1~100)",
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xfff2f2f3),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: AsyncButtonBuilder(
                            onPressed: () async {
                              if (enhanceTextFieldController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // 바깥 영역 터치시 닫을지 여부
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('에러'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text('값을 입력하세요'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                                throw 'Data empty';
                              } else {
                                int inputNum =
                                    int.parse(enhanceTextFieldController.text);

                                lastMiliSecondTime = 0;
                                _stopWatchTimer.onStartTimer();

                                if (0 < inputNum && inputNum <= 10) {
                                  print('이퀄라이징 시작');

                                  // #1 request job
                                  var res = apiHandler
                                      .createPreSignEqualize(inputNum);
                                  res.then((val) {
                                    print('주소 생성 완료');
                                    // 이퀄라이징 시작
                                    for (var idx = 0; idx < inputNum; idx++) {
                                      apiHandler.startEqualize(idx, val);
                                    }
                                  }).catchError((error) async {
                                    // error가 해당 에러를 출력
                                    print('error: $error');
                                    throw 'error';
                                  });

                                  // #2 wait job is done and stop timer
                                  await Future.delayed(
                                      const Duration(seconds: 30), () {
                                    setState(() {
                                      _stopWatchTimer.onStopTimer();
                                      _stopWatchTimer.onResetTimer();
                                    });
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible:
                                          true, // 바깥 영역 터치시 닫을지 여부
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('에러'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text('범위내의 값을 입력하세요. (1~100)'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('확인'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  throw 'Out of Data range';
                                }
                              }
                            },
                            loadingWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: _stopWatchTimer.rawTime.value,
                                  builder: (context, snap) {
                                    final value = snap.data!;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value,
                                            hours: false);
                                    lastMiliSecondTime = value;
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            displayTime,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            builder: (context, child, callback, buttonState) {
                              final buttonColor = buttonState.when(
                                idle: () => Colors.blue,
                                loading: () => Colors.green,
                                success: () => Colors.orangeAccent,
                                error: (_, __) => Colors.orange,
                              );

                              return OutlinedButton(
                                onPressed: callback,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: buttonColor,
                                ),
                                child: child,
                              );
                            },
                            child: Text(
                                'Run Equalize  < $lastMiliSecondTime ms >'),
                          )),
                    ),
                  ],
                ),
              ),

              // 이퀄라이징 평가
              Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0x1f000000),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              "이퀄라이징 평가",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 20,
                                color: Color(0xff000000),
                              ),
                            ),
                            TextField(
                              controller: enhanceTextFieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                hintText: "시료 수 입력(1~100)",
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xfff2f2f3),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: AsyncButtonBuilder(
                            onPressed: () async {
                              if (enhanceTextFieldController.text.isEmpty) {
                                showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // 바깥 영역 터치시 닫을지 여부
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('에러'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text('값을 입력하세요'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('확인'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                                throw 'Data empty';
                              } else {
                                int inputNum =
                                    int.parse(enhanceTextFieldController.text);

                                lastMiliSecondTime = 0;
                                _stopWatchTimer.onStartTimer();

                                if (0 < inputNum && inputNum <= 10) {
                                  print('이퀄라이징 평가 시작');

                                  // #1 request job
                                  // 1) request stt to go_server
                                  // 2) wait stt result
                                  // 3) compare('s3::stt/$_original.txt' and 's3::stt/$.txt) to use python cer code
                                  
                                  // var res = apiHandler.createPreSignEqualize(inputNum);
                                  // res.then((val) {
                                  //   print('주소 생성 완료');
                                  //   // 이퀄라이징 평가 시작
                                  //   for (var idx = 0; idx < inputNum; idx++) {
                                  //     apiHandler.startEqualize(idx, val);
                                  //   }
                                  // }).catchError((error) async {
                                  //   // error가 해당 에러를 출력
                                  //   print('error: $error');
                                  //   throw 'error';
                                  // });

                                  // #2 wait job is done and stop timer
                                  await Future.delayed(const Duration(seconds: 30), () {

                                    setState(() {
                                      _stopWatchTimer.onStopTimer();
                                      _stopWatchTimer.onResetTimer();
                                    });
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible:
                                          true, // 바깥 영역 터치시 닫을지 여부
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('에러'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: const <Widget>[
                                                Text('범위내의 값을 입력하세요. (1~100)'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('확인'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  throw 'Out of Data range';
                                }
                              }
                            },
                            loadingWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                                StreamBuilder<int>(
                                  stream: _stopWatchTimer.rawTime,
                                  initialData: _stopWatchTimer.rawTime.value,
                                  builder: (context, snap) {
                                    final value = snap.data!;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value,
                                            hours: false);
                                    lastMiliSecondTime = value;
                                    return Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            displayTime,
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            value.toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            builder: (context, child, callback, buttonState) {
                              final buttonColor = buttonState.when(
                                idle: () => Colors.blue,
                                loading: () => Colors.green,
                                success: () => Colors.orangeAccent,
                                error: (_, __) => Colors.orange,
                              );

                              return OutlinedButton(
                                onPressed: callback,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: buttonColor,
                                ),
                                child: child,
                              );
                            },
                            child:
                                Text('Run Equalize  < $lastMiliSecondTime ms >'),
                          )),
                    ),
                  ],
                ),
              ),

              OutlinedButton(
                  child: const Text("Save Excel"),
                  onPressed: () async {
                    apiHandler.saveData();
                  }),
            ],
          ),
        ));
  }
}
