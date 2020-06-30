import 'package:dog_pal/navigators/app_navigator.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _width = 300;
  double _height = 300;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]); // set full screen

    var _localStorage = Provider.of<LocalStorage>(context, listen: false);

    _localStorage.initLocalStorage().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _width = 75;
          _height = 75;
        });

        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.of(context)
              .pushNamed(AppRoutes.DECISIONS_SCREEN, arguments: _localStorage);
        });
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    ScreenUtil.init(context,
        width: 1242, height: 2688, allowFontScaling: true); //Init screen util
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(
        SystemUiOverlay.values); //exit full screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Fader(
          child: AnimatedContainer(
            curve: Curves.easeOutCubic,
            duration: Duration(milliseconds: 300),
            width: _width,
            height: _height,
            child: Image.asset('assets/paw.png'),
          ),
        ),
      ),
    );
  }
}
