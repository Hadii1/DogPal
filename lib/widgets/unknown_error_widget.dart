import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'fade_in_widget.dart';

class UnknownErrorWidget extends StatefulWidget {
  const UnknownErrorWidget({this.onRetry});
  final Function onRetry;

  @override
  _UnknownErrorWidgetState createState() => _UnknownErrorWidgetState();
}

class _UnknownErrorWidgetState extends State<UnknownErrorWidget> {
  String _image;

  @override
  void initState() {
    _image = getRandomDogImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Fader(
      child: Container(
          color: yellowishColor,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(_image),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Unknown error',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(56),
                      ),
                    ),
                    Icon(
                      Icons.error,
                      color: blackishColor,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => widget.onRetry(),
                child: Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(50),
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                    fontFamily: 'OpenSans',
                  ),
                ),
              )
            ],
          )),
    );
  }
}
