/*
 * Maintained by jemo from 2019.12.23 to now
 * Created by jemo on 2019.12.23 16:32:20
 * Version
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../colors.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class Version extends StatefulWidget {

  @override
  VersionState createState() => VersionState();

}

class VersionState extends State<Version> {

  String currentVersionName = '';
  int currentVersionNumber;
  String serviceVersionName;
  int serviceVersionNumber;
  String serviceVersionUrl;

  @override
  void initState() {
    super.initState();
    getCurrentVersion();
    getServiceVersion();
  }

  void getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final versionName = packageInfo.version;
    final versionNumber = int.parse(packageInfo.buildNumber);
    setState(() {
      currentVersionName = versionName;
      currentVersionNumber = versionNumber;
    });
  }

  void getServiceVersion() async {
    final query = r'''
      query {
        version {
          versionName
          versionNumber
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
        final versionName = version['versionName'];
        final versionNumber = version['versionNumber'];
        final versionUrl = version['versionUrl'];
        if(versionNumber != '') {
          setState(() {
            serviceVersionName = versionName;
            serviceVersionNumber = int.parse(versionNumber);
            serviceVersionUrl = versionUrl;
          });
        }
      }
    }
    catch(error) {
      print('VersionGetServiceVersionError: $error');
    }
  }

  bool checkLatest() {
    bool isLatest = true;
    if(serviceVersionNumber != null &&
      currentVersionNumber != null) {
      if(serviceVersionNumber > currentVersionNumber) {
        isLatest = false;
      }
    }
    return isLatest;
  }

  void onVersionCardTapped() {
    final isLatest = checkLatest();
    if(isLatest) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('当前为最新版本'),
            content: Text('当前版本：$currentVersionName，无需更新'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('更新版本'),
            content: Text('最新版本：$serviceVersionName，当前版本：$currentVersionName'),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('去更新'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if(await canLaunch(serviceVersionUrl)) {
                    await launch(serviceVersionUrl);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('无法打开: $serviceVersionUrl'),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLatest = checkLatest();
    return Card(
      child: InkWell(
        onTap: onVersionCardTapped,
        child: ListTile(
          leading: Icon(Icons.arrow_upward),
          title: Text('版本更新'),
          trailing: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                isLatest ?
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(currentVersionName),
                  ) :
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Text.rich(
                      TextSpan(
                        text: '有新版本: ',
                        children: <TextSpan>[
                          TextSpan(
                            text: serviceVersionName,
                            style: TextStyle(
                              color: Color(TsuenWanWestRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
