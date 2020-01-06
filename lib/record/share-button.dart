/*
 * Maintained by jemo from 2019.12.17
 * Created by jemo on 2019.12.7 10:13:15
 * Share button
 */

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'time-record-pie-chart.dart';
import '../custom-simple-dialog.dart';
import '../config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShareButton extends StatefulWidget {

  ShareButton({
    Key key,
    this.timeRecord,
    this.timeCategory,
    this.lastDayTimeRecord,
    this.selectedDate,
  }) : super(key: key);

  var timeRecord;
  var timeCategory;
  var lastDayTimeRecord;
  var selectedDate;

  @override
  ShareButtonState createState() => ShareButtonState();

}

class ShareButtonState extends State<ShareButton> {

  GlobalKey repaintBoundaryGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initFluwx();
  }

  void initFluwx() async {
    await fluwx.registerWxApi(
      appId: wechatAppid,
    );
    await fluwx.isWeChatInstalled();
  }

  getServiceVersionUrl() async {
    final query = r'''
      query {
        version {
          versionUrl
        }
      }
    ''';
    final data = {
      'query': query,
    };
    final body = json.encode(data);
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );
      if(response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'];
        final version = data['version'];
        final versionUrl = version['versionUrl'];
        return versionUrl;
      }
    }
    catch(error) {
      print('ShareButtonGetServiceVersionError: $error');
    }
  }

  void onShareIconPressed(fluwx.WeChatScene scene) async {
    RenderRepaintBoundary boundary = repaintBoundaryGlobalKey.currentContext.findRenderObject();
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    ui.Image image = await boundary.toImage(
      pixelRatio: devicePixelRatio,
    );
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData.buffer.asUint8List();
    fluwx.share(fluwx.WeChatShareImageModel.fromUint8List(
      imageData: uint8List,
      scene: scene,
    ));
    Navigator.of(context).pop();
  }

  void onShareButtonPressed() async {
    final serviceVersionUrl = await getServiceVersionUrl();
    final selectedDate = widget.selectedDate;
    final weekdayMap = {
      1: '星期一',
      2: '星期二',
      3: '星期三',
      4: '星期四',
      5: '星期五',
      6: '星期六',
      7: '星期日',
    };
    final weekday = weekdayMap[selectedDate.weekday];
    final selectedDateString = '${selectedDate.year}.${selectedDate.month}.${selectedDate.day} ${weekday}';
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: CustomSimpleDialog(
            dialogMargin: EdgeInsets.symmetric(
              horizontal: 0,
            ),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('分享到'),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RepaintBoundary(
                  key: repaintBoundaryGlobalKey,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 385,
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: 10.0,
                            bottom: 20.0,
                          ),
                          child: Text(
                            selectedDateString,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: 5.0,
                          ),
                          child: SizedBox(
                            height: 240,
                            width: 385,
                            child: TimeRecordPieChart(
                              timeRecord: widget.timeRecord,
                              timeCategory: widget.timeCategory,
                              lastDayTimeRecord: widget.lastDayTimeRecord,
                            ),
                          ),
                        ),
                        Container(
                          width: 390,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: QrImage(
                                    data: serviceVersionUrl ?? '',
                                    version: QrVersions.auto,
                                    padding: EdgeInsets.all(0),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    '小福时间助手',
                                    style: TextStyle(
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        onShareIconPressed(fluwx.WeChatScene.SESSION);
                      },
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/icon/wechat-48-48.png',
                              width: 45,
                              height: 45,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text('微信'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        onShareIconPressed(fluwx.WeChatScene.TIMELINE);
                      },
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/icon/time-line-48-48.png',
                              width: 45,
                              height: 45,
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Text('朋友圈'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share),
      onPressed: onShareButtonPressed,
    );
  }
}
