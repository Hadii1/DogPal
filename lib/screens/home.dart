import 'dart:math';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/navigators/dogs_screen_navigator.dart';
import 'package:dog_pal/navigators/profile_navigator.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dog_pal/bloc/post_details_bloc.dart';

class Home extends StatefulWidget {
  const Home();
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  List<GlobalKey<NavigatorState>> _navigatorsKeys;

  List<AnimationController> _faders;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _bottomNavIndex = 0;

  AppBloc _appBloc;

  LocalStorage _localStorage;

  final List<String> _errorMsgs = [
    'Couldnt\'t add post. There seems to be an error from our side.',
    'Oops.. we couldn\'t add your post. Looks like somethings went wrong.',
    'We\'ve had an error adding your post.',
  ];

  @override
  void initState() {
    _appBloc = Provider.of<AppBloc>(context, listen: false);
    _localStorage = Provider.of<LocalStorage>(context, listen: false);

    _navigatorsKeys = List.generate(
      2,
      (int index) => GlobalKey(),
    );

    _faders = List.generate(
      2,
      (ind) {
        return AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        );
      },
    );

    _faders[_bottomNavIndex].value = 1;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        //Show first location:

        String display = _localStorage.getUserLocationData().display;
        String town = _localStorage.getUserLocationData().town;

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Showing results in ${display ?? town}'),
          ),
        );
      },
    );

    _appBloc.operationStatus.listen((status) {
      switch (status) {
        case PostAdditionStatus.adding:
          _showProgressNotification();
          break;
        case PostAdditionStatus.successful:
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _showSuccessNotification();
          break;
        case PostAdditionStatus.failed:
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _showFailureNotification();
          break;
      }
    });

    super.initState();
  }

  void _showFailureNotification() {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(_errorMsgs[Random().nextInt(3)]),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => _appBloc.onRetryPressed(),
        ),
      ),
    );
  }

  void _showProgressNotification() {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Wrap(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('Adding Post...'),
                ),
                SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        duration: Duration(days: 100),
      ),
    );
  }

  void _showSuccessNotification() {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Post Successfully Added'),
            Icon(Icons.check_box, color: Theme.of(context).accentColor),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _navigateToPost(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await _navigatorsKeys[_bottomNavIndex].currentState.maybePop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: _buildNavigationBar(),
        body: SafeArea(
          top: false,
          child: Stack(
            fit: StackFit.expand,
            children: List.generate(2, (index) {
              final Widget view = FadeTransition(
                opacity: _faders[index].drive(
                  CurveTween(curve: Curves.easeOutCubic),
                ),
                child: KeyedSubtree(
                  child: getChild(index),
                ),
              );

              if (index == _bottomNavIndex) {
                _faders[index].forward();
                return view;
              } else {
                _faders[index].reverse();
                if (_faders[index].isAnimating) {
                  return IgnorePointer(child: view);
                }
                return Offstage(child: view);
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget getChild(int index) {
    switch (index) {
      case 0:
        return DogsScreenNavigator(_navigatorsKeys[0]);
        break;
      case 1:
        return ProfileNavigator(_navigatorsKeys[1]);
        break;
      default:
        return null;
    }
  }

  BottomNavigationBar _buildNavigationBar() {
    return BottomNavigationBar(
      unselectedFontSize: 35.sp,
      elevation: 12,
      iconSize: 70.sp,
      currentIndex: _bottomNavIndex,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.shifting,
      selectedItemColor: Colors.deepOrangeAccent,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.dog),
          title: Text('Dogs'),
          backgroundColor: yellowishColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.account),
          title: Text('Profile'),
          backgroundColor: yellowishColor,
        )
      ],
      onTap: (index) {
        setState(() {
          if (_bottomNavIndex == index) {
            _navigatorsKeys[_bottomNavIndex]
                .currentState
                .popUntil((route) => route.isFirst);
          } else {
            _bottomNavIndex = index;
          }
        });
      },
    );
  }

  //TODO: put into the app router class
  void _navigateToPost(BuildContext context) {
    Widget child;

    switch (_appBloc.dogPost.type) {
      case 'lost':
        child = LostDogDetailsScreen(
          post: _appBloc.dogPost,
        );
        break;

      case 'adopt':
        child = AdoptionDogWall(
          AdoptDetailsArgs(
            post: _appBloc.dogPost,
          ),
        );
        break;

      case 'mate':
        child = MateDogDetailsScreen(
          MateDetailsArgs(
            post: _appBloc.dogPost,
          ),
        );
        break;

      default:
        throw PlatformException(code: 'post type isn\'t valid');
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Provider(
            create: (_) => PostDeletionBloc(
              appBloc: _appBloc,
              dogPostsBloc: Provider.of<DogPostsBloc>(context),
              profileBloc: Provider.of<ProfileBloc>(context),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
