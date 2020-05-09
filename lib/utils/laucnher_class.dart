import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchersOptions extends StatelessWidget {
  const LaunchersOptions(this.number, this.email);

  final String number;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkResponse(
                onTap: () async {
                  if (email.isNotEmpty) {
                    if (await canLaunch('mailto:$email')) {
                      launch('mailto:$email');
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: _createText(email),
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: email),
                              );
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Copied'),
                                      Icon(
                                        Icons.check_box,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 35,
                  child: Icon(
                    Icons.email,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Email'),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkResponse(
                onTap: () async {
                  if (number.isNotEmpty) {
                    if (await canLaunch('tel:$number')) {
                      if (number.isNotEmpty) launch('tel:$number');
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: _createText(number),
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: number),
                              );
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Copied'),
                                      Icon(
                                        Icons.check_box,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: number.isNotEmpty
                      ? Colors.green
                      : Colors.grey.withOpacity(0.2),
                  child: Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Call',
                  style: TextStyle(
                    color: number.isNotEmpty ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkResponse(
                onTap: () async {
                  if (number.isNotEmpty) {
                    if (await canLaunch('sms:$number')) {
                      if (number.isNotEmpty) {
                        launch('sms:$number');
                      }
                    } else {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: _createText(number),
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: number),
                              );

                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Copied'),
                                      Icon(
                                        Icons.check_box,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: number.isNotEmpty
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.2),
                  child: Icon(
                    Icons.sms,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Sms',
                  style: TextStyle(
                    color: number.isNotEmpty ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  RichText _createText(String info) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text:
                'The action isn\'t supported on this phone. Please contact the owner using:\n',
            style: TextStyle(color: blackishColor),
          ),
          TextSpan(
            text: info,
            style: TextStyle(
              color: Color(0xff007A7D),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
