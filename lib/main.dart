import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mediaapi_client/src/media_api_handle.dart';
import 'package:flutter_mediaapi_client/src/util/env.dart';
import 'package:flutter_mediaapi_client/src/widget/token_condition_widget.dart';

void main() {
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
  final textfieldController = TextEditingController();

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
          leading: const Icon(
            Icons.arrow_back,
            color: Color(0xff212435),
            size: 24,
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
                children: const [
                  Text(
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
                  TokenCondition(),
                ],
              ),
              const Divider(
                color: Color(0xff808080),
                height: 16,
                thickness: 0,
                indent: 0,
                endIndent: 0,
              ),

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
                      flex: 4,
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
                              controller: textfieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly],
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
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: MaterialButton(
                          onPressed: () {
                            if(textfieldController.text.isEmpty)
                            {
                              showDialog(
                                context: context,
                                barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                builder: (BuildContext context) {
                                  return  AlertDialog(
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
                            }
                            else {
                              int inputNum = int.parse(textfieldController.text);
                              if(0 < inputNum && inputNum <=10){
                                print('노이즈캔슬링 시작');
                                // 1 링크 생성 요청 및 응답
                                // param - 링크 수
                                // return - 생성된 링크 배열
                                var res = apiHandler.createPreSignUrl(inputNum);

                                // 2 노이즈캔슬링 시작 (순차형, 분산형 방법 미정)
                                // param - 생성된 링크 배열
                                // return - 노이즈 캔슬링 jobid or void
                                
              
                              }
                              else {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return  AlertDialog(
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
                              }
                            }
                          },
                          color: const Color(0xffffffff),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side:
                                BorderSide(color: Color(0xff808080), width: 1),
                          ),
                          padding: const EdgeInsets.all(16),
                          textColor: const Color(0xff000000),
                          height: 40,
                          minWidth: 140,
                          child: const Text(
                            "실행",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
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
                      flex: 4,
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
                              controller: textfieldController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly],
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
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: MaterialButton(
                          onPressed: () {
                            if(textfieldController.text.isEmpty)
                            {
                              showDialog(
                                context: context,
                                barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                builder: (BuildContext context) {
                                  return  AlertDialog(
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
                            }
                            else {
                              int inputNum = int.parse(textfieldController.text);
                              if(0 < inputNum && inputNum <=10){
                                print('이퀄라이징 시작');
                              }
                              else {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return  AlertDialog(
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
                              }
                            }
                          },
                          color: const Color(0xffffffff),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side:
                                BorderSide(color: Color(0xff808080), width: 1),
                          ),
                          padding: const EdgeInsets.all(16),
                          textColor: const Color(0xff000000),
                          height: 40,
                          minWidth: 140,
                          child: const Text(
                            "실행",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ));
  }
}
