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

class ShareButton extends StatefulWidget {

  ShareButton({
    Key key,
    this.timeRecord,
    this.timeCategory,
    this.lastDayTimeRecord,
  }) : super(key: key);

  var timeRecord;
  var timeCategory;
  var lastDayTimeRecord;

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

  void onShareIconPressed(fluwx.WeChatScene scene) async {
    RenderRepaintBoundary boundary = repaintBoundaryGlobalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData.buffer.asUint8List();
    fluwx.share(fluwx.WeChatShareImageModel.fromUint8List(
      imageData: uint8List,
      scene: scene,
    ));
    Navigator.of(context).pop();
  }

  void onShareButtonPressed() {
    showDialog(
      barrierDismissible: true,
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
              RepaintBoundary(
                key: repaintBoundaryGlobalKey,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: SizedBox(
                    height: 240,
                    width: 400,
                    child: TimeRecordPieChart(
                      timeRecord: widget.timeRecord,
                      timeCategory: widget.timeCategory,
                      lastDayTimeRecord: widget.lastDayTimeRecord,
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
