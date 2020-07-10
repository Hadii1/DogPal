import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/bloc/decisions_bloc.dart';
import 'package:dog_pal/navigators/app_navigator.dart';
import 'package:dog_pal/screens/login.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

//This file contains all initialization steps (auth check,location check and storage init)

class DecisionsScreen extends StatefulWidget {
  DecisionsScreen({Key key}) : super(key: key);

  @override
  _DecisionsScreenState createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  DecisionsBloc _bloc;
  LocalStorage _localStorage;
  @override
  void initState() {
    _bloc = Provider.of<DecisionsBloc>(context, listen: false);
    _localStorage = Provider.of<LocalStorage>(context, listen: false);

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
                      return AuthBloc(_localStorage);
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
    Navigator.of(context, rootNavigator: true)
        .pushNamed(AppRoutes.HOME, arguments: _localStorage);
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
              padding: const EdgeInsets.only(bottom: 24),
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
