import 'dart:async';
import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/navigators/app_navigator.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({this.onDone});
  final Function onDone; //Used once from the decision screen
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Size _size;
  AuthBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<AuthBloc>(context, listen: false);

    _bloc.shouldNavigate.listen(
      (_) {
        widget.onDone == null ? Navigator.of(context).pop() : widget.onDone();
      },
    );

    _bloc.error.listen(
      (error) {
        if (error == GeneralConstants.NO_INTERNET_CONNECTION) {
          _scaffoldKey.currentState.showSnackBar(
            noConnectionSnackbar(),
          );
        } else {
          _scaffoldKey.currentState.showSnackBar(
            errorSnackBar(error),
          );
        }
      },
    );

    //hide status bar:
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //show status bar:
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    _bloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _size = MediaQuery.of(context).size;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 80,
                  duration: Duration(milliseconds: 500),
                  child: widget,
                ),
                children: [
                  _welcomeText(),
                  _ImageShow(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.08,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 80,
                  duration: Duration(milliseconds: 800),
                  child: widget,
                ),
                children: [
                  _fbButton(),
                  _gmailButton(),
                  _termsWidget(),
                  _laterWidget(),
                ],
              ),
            ),
          ),

          //Loading widget
          StreamBuilder<bool>(
            initialData: false,
            stream: _bloc.loading,
            builder: (_, snapshot) {
              return snapshot.data
                  ? Container(
                      color: Colors.black12,
                      child: Center(
                        child: SpinKitDoubleBounce(
                          duration: Duration(seconds: 1),
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    )
                  : Container();
            },
          )
        ],
      ),
    );
  }

  Widget _welcomeText() {
    return Padding(
      padding: EdgeInsets.only(top: _size.height * 0.07, left: 24),
      child: Text(
        'Welcome',
        style: TextStyle(
            color: blackishColor,
            fontSize: ScreenUtil().setSp(120),
            fontFamily: 'Pacifico'),
      ),
    );
  }

  Widget _fbButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: _size.width * 0.1,
        right: _size.width * 0.1,
        top: 24.h,
      ),
      child: OutlineButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: blackishColor,
        highlightedBorderColor: Theme.of(context).primaryColor,
        borderSide: BorderSide(color: blackishColor, width: 0.5),
        onPressed: () => _bloc.signIn(SignInMethod.fb),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Continue with facebook',
            style: TextStyle(
              color: blackishColor,
              fontSize: ScreenUtil().setSp(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gmailButton() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: _size.width * 0.1, vertical: 24.h),
      child: OutlineButton(
        borderSide: BorderSide(color: blackishColor, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: blackishColor,
        highlightedBorderColor: Theme.of(context).primaryColor,
        onPressed: () => _bloc.signIn(SignInMethod.gmail),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '  Continue with gmail  ',
            style: TextStyle(
              color: blackishColor,
              fontSize: ScreenUtil().setSp(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _laterWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
      child: InkWell(
        key: Key('laterText'),
        splashColor: Colors.transparent,
        onTap: () => widget.onDone == null
            ? Navigator.of(context).pop()
            : widget.onDone(),
        child: Text(
          'Later',
          style: TextStyle(
            color: blackishColor,
            fontSize: ScreenUtil().setSp(44),
          ),
        ),
      ),
    );
  }

  Widget _termsWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 64.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.w500,
            fontSize: ScreenUtil().setSp(35),
          ),
          children: [
            const TextSpan(
              text: 'By signing in you agree to the ',
              style: TextStyle(color: Colors.black87),
            ),
            TextSpan(
              text: 'terms and conditions',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.of(context, rootNavigator: true)
                    .pushNamed(AppRoutes.TERMS_SCREEN),
            )
          ],
        ),
      ),
    );
  }
}

class _ImageShow extends StatefulWidget {
  const _ImageShow();

  @override
  __ImageShowState createState() => __ImageShowState();
}

class __ImageShowState extends State<_ImageShow> {
  PageController _controller;
  int _index = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    Timer.periodic(Duration(seconds: 5), (_) {
      if (_controller.hasClients) {
        _controller.animateToPage(
          _incrementIndex(),
          duration: Duration(seconds: 2),
          curve: Curves.easeOutCubic,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _incrementIndex() {
    if (_index == 2) {
      _index = 0;
    } else {
      _index++;
    }

    return _index;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Image.asset(
            'assets/cute_dog.png',
          ),
          Image.asset(
            'assets/cute_dog_2.png',
          ),
          Image.asset(
            'assets/cute_dog_3.png',
          ),
        ],
      ),
    );
  }
}
