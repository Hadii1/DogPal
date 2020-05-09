import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/bloc/decisions_bloc.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/screens/login.dart';
import 'package:dog_pal/screens/home.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

//This file contains all initialization steps (auth check,location check and storage init)

//We init the local storage while the splash screen shows

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

    var _bloc = Provider.of<LocalStorage>(context, listen: false);

    _bloc.initializeHive().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _width = 75;
          _height = 75;
        });

        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) {
                return Provider<DecisionsBloc>(
                  create: (_) {
                    var localStorage =
                        Provider.of<LocalStorage>(context, listen: false);

                    return DecisionsBloc(localStorage);
                  },
                  child: DecisionsScreen(),
                );
              },
            ),
          );
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

class DecisionsScreen extends StatefulWidget {
  DecisionsScreen({Key key}) : super(key: key);

  @override
  _DecisionsScreenState createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  DecisionsBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<DecisionsBloc>(context, listen: false);

    _bloc.shouldNavigate.listen((_) {
      _navigateHome();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.setFirstState();
    });

    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DecisionState>(
        stream: _bloc.state,
        builder: (_, snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: (() {
              switch (snapshot.data) {
                case DecisionState.unAuthenticated:
                  return Provider<AuthBloc>(
                    create: (_) {
                      var localStorage =
                          Provider.of<LocalStorage>(context, listen: false);
                      return AuthBloc(localStorage);
                    },
                    child: LoginScreen(
                      onDone: () => _bloc.checkLocationPermission(),
                    ),
                  );
                  break;

                case DecisionState.askingPermission:
                  return _AskLocationWidget();
                  break;

                case DecisionState.fetchingLocation:
                  return _LocationFetching();
                  break;

                default:
                  return _LoadingWidget();
              }
            }()),
          );
        },
      ),
    );
  }

  void _navigateHome() {
    LocalStorage _localStorage =
        Provider.of<LocalStorage>(context, listen: false);

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) {
          return MultiProvider(
            providers: [
              Provider<ProfileBloc>(
                create: (_) => ProfileBloc(_localStorage),
              ),
              Provider<LostBloc>(
                create: (_) => LostBloc(_localStorage),
              ),
              Provider<AdoptBloc>(
                create: (_) => AdoptBloc(_localStorage),
              ),
              Provider<MateBloc>(
                create: (_) => MateBloc(_localStorage),
              ),
            ],
            child: Home(
              locationNotification: _bloc.locationNotification,
            ),
          );
        },
      ),
    );
  }
}

//This is shown only when we're checking if the location permission is granted.
//It usually takes so little time that showing a loading state would look like
//a flicker. So we wait one second before showing it were mostly its
//not gonna show the loading unless it's really taking time.
class _LoadingWidget extends StatefulWidget {
  @override
  __LoadingWidgetState createState() => __LoadingWidgetState();
}

class __LoadingWidgetState extends State<_LoadingWidget> {
  bool _showLoading = false;
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showLoading = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _showLoading
        ? Container(
            child: Center(
              child: SpinKitDualRing(
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        : Container();
  }
}

class _LocationFetching extends StatelessWidget {
  const _LocationFetching({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Image.asset('assets/location.jpg'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SpinKitDualRing(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Fader(
            child: Text(
              'Fetching Location ...',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(48),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _AskLocationWidget extends StatelessWidget {
  const _AskLocationWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DecisionsBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Image.asset('assets/location.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'For better experience and more relevant posts, enable location access.',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: FlatButton(
                  child: Text(
                    'Enable Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    bloc.accessLocation();
                  },
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => bloc.skipPressed(),
                splashColor: Colors.transparent,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: ScreenUtil().setSp(44),
                    fontFamily: 'Comfortaa',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
