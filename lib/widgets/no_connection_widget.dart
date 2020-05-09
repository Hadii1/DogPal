import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'fade_in_widget.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({@required this.onRetry});

  final Function onRetry;

  @override
  Widget build(BuildContext context) {
    return Fader(
      child: Center(
        child: Container(
          color: yellowishColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.signal_wifi_off, size: 75, color: blackishColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(52),
                  ),
                ),
              ),
              InkWell(
                onTap: () => onRetry(),
                child: Text(
                  'Tap to Retry',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: ScreenUtil().setSp(48),
                    fontWeight: FontWeight.w200,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
