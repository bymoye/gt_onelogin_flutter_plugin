import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:gt_onelogin_flutter_plugin/gt_onelogin_flutter_plugin.dart';

const androidOLAppId = "b41a959b5cac4dd1277183e074630945";
const String tag = "| Geetest | Example | ";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GtOneloginFlutterPlugin oneLoginPlugin = GtOneloginFlutterPlugin();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    String appId;
    if (Platform.isAndroid) {
      appId = androidOLAppId;
    } else {
      //TODO appId
      appId = "b41a959b5cac4dd1277183e074630945";
    }
    oneLoginPlugin.init(appId);

    oneLoginPlugin.addEventListener(
        onBackButtonClick,
        onAuthButtonClick,
        onSwitchButtonClick,
        onTermItemClick,
        onTermCheckBoxClick);
  }

  void onBackButtonClick(Map<String, dynamic>? message) async {
    debugPrint(tag + "onBackButtonClick");
  }
  void onAuthButtonClick(Map<String, dynamic>? message) async {
    debugPrint(tag + "onAuthButtonClick");
  }
  void onSwitchButtonClick(Map<String, dynamic>? message) async {
    debugPrint(tag + "onSwitchButtonClick");
  }
  void onTermItemClick(Map<String, dynamic>? message) async {
    debugPrint(tag + "onTermItemClick");
  }
  void onTermCheckBoxClick(Map<String, dynamic>? message) async {
    debugPrint(tag + "onTermCheckBoxClick");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Welcome to Geetest OneLogin\n'),
              TextButton(
                  onPressed: () {
                    requestToken();
                  },
                  child: const Text("OneLogin start")),
            ],
          ),
        ),
      ),
    );
  }

  //拉起授权页
  requestToken() {
    var configure = OLUIConfigure();
    configure.supportedinterfaceOrientations = OLIOSInterfaceOrientation.landscape;
    configure.isDialogStyle = true;
    configure.dialogCornersRadius = 40;
    oneLoginPlugin.requestToken(configure).then((result) async {
      debugPrint(result.toString());
      int status = result["status"];
      if (status == 200) {
        Map<String, String> params = HashMap();
        params["process_id"] = result["process_id"];
        params["token"] = result["token"];
        params["authcode"] = result["authcode"];
        params["id_2_sign"] = result["app_id"];
        await verifyToken(params);
      } else {
        oneLoginPlugin.dismissAuthView();
      }
    });
  }

  //一键登录校验token
  Future<dynamic> verifyToken(Map<String, String> params) async {
    params.forEach((key, value) {
      debugPrint("$key : $value");
    });
    String _url = "https://onepass.geetest.com/onelogin/result";

    try {
      final response = await http.post(Uri.parse(_url),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
          },
          body: params);
      String toast;
      if (response.statusCode == 200) {
        toast = "登录成功";
        debugPrint("Validate success. response: " + response.body);
      } else {
        toast = "登录失败：${response.statusCode}";
        debugPrint("Validate failed. response status: ${response.statusCode}");
      }
      oneLoginPlugin.dismissAuthView();
      Fluttertoast.showToast(
          msg: toast,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white10,
          textColor: Colors.black87,
          fontSize: 16.0
      );
    } on SocketException {
      // 未联网时无法完成二次验证，在此处理无网络时的逻辑
      debugPrint("No Internet Connection");
      oneLoginPlugin.dismissAuthView();
    }
  }
}
