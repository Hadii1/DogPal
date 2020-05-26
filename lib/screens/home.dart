import 'dart:math';
import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/navigators/adopt_navigator.dart';
import 'package:dog_pal/navigators/lost_navigator.dart';
import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/navigators/profile_navigator.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({this.locationNotification});
  final SnackBar locationNotification;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin<Home> {
  List<GlobalKey<NavigatorState>> _navigatorsKeys;

  List<AnimationController> _faders;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _bottomNavIndex = 2;

  AppBloc _appBloc;

  List<String> _errorMsgs = [
    'Couldnt\'t add post. There seems to be an error from our side.',
    'Oops.. we couldn\'t add your post. Looks like somethings went wrong.',
    'We\'ve had an error adding your post.',
  ];

  @override
  void initState() {
    _navigatorsKeys = List.generate(
      4,
      (int index) => GlobalKey(),
    );

    _faders = List.generate(
      4,
      (ind) {
        return AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        );
      },
    );

    _faders[_bottomNavIndex].value = 1;

    _appBloc = Provider.of<AppBloc>(context, listen: false);

    //Show any information from the decisions screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.locationNotification != null) {
        _scaffoldKey.currentState.showSnackBar(widget.locationNotification);
      }
    });

    _appBloc.notifications.listen(
      (snack) {
        _scaffoldKey.currentState.showSnackBar(snack);
      },
    );

    _appBloc.postsToAddStream.listen(
      (func) async {
        _appBloc.lastFunction = func;
        _appBloc.currentlyAdding = true;

        //notify the user of the operation
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

        bool succeeded =
            await func().timeout(Duration(seconds: 60), onTimeout: () => false);

        _scaffoldKey.currentState.hideCurrentSnackBar();

        _appBloc.currentlyAdding = false;

        if (succeeded) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              duration: Duration(seconds: 5),
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

          _refreshPosts();
        } else {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(_errorMsgs[Random().nextInt(3)]),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () async =>
                    _appBloc.postsCtrl.sink.add(_appBloc.lastFunction),
              ),
            ),
          );
        }
      },
    );

    super.initState();
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
            children: List.generate(4, (index) {
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
        return AdoptNavigator(_navigatorsKeys[0]);
        break;
      case 1:
        return MateNavigator(_navigatorsKeys[1]);
        break;
      case 2:
        return LostNavigator(_navigatorsKeys[2]);
        break;
      case 3:
        return ProfileNavigator(_navigatorsKeys[3]);
        break;
      default:
        return null;
    }
  }

  BottomNavigationBar _buildNavigationBar() {
    return BottomNavigationBar(
      selectedFontSize: 45.sp,
      unselectedFontSize: 35.sp,
      elevation: 12,
      selectedIconTheme: IconThemeData(size: 85.sp),
      iconSize: 75.sp,
      currentIndex: _bottomNavIndex,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.shifting,
      selectedItemColor: Colors.deepOrangeAccent,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeHeart),
          title: Text('Adopt'),
          backgroundColor: yellowishColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.heart),
          title: Text('Mate'),
          backgroundColor: yellowishColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.emoticonSad),
          title: Text('Lost'),
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

  void _navigateToPost(BuildContext context) {
    Widget child;
    print(_appBloc.dogPost.type);
    switch (_appBloc.dogPost.type) {
      case 'lost':
        child = LostDogDetailsScreen(
          LostDetailsArgs(
            post: _appBloc.dogPost,
            bloc: Provider.of<LostBloc>(context, listen: false),
          ),
        );
        break;

      case 'adopt':
        child = AdoptionDogWall(
          AdoptDetailsArgs(
            post: _appBloc.dogPost,
            bloc: Provider.of<AdoptBloc>(context, listen: false),
          ),
        );
        break;

      case 'mate':
        child = MateDogDetailsScreen(
          MateDetailsArgs(
            post: _appBloc.dogPost,
            bloc: Provider.of<MateBloc>(context, listen: false),
          ),
        );
        break;

      default:
        throw PlatformException(code: 'post type isn\'t valid');
    }
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) {
          return child;
        },
      ),
    );
  }

  void _refreshPosts() {
    final _localStorage = Provider.of<LocalStorage>(context, listen: false);

    DogPostsBloc bloc;
    switch (_appBloc.dogPost.type) {
      case 'lost':
        bloc = Provider.of<LostBloc>(context, listen: false);
        break;

      case 'adopt':
        bloc = Provider.of<AdoptBloc>(context, listen: false);
        break;

      case 'mate':
        bloc = Provider.of<MateBloc>(context, listen: false);
        break;

      default:
        throw PlatformException(code: 'post type isn\'t valid');
    }

    //to search for the last post added we edit the location we're searching in to the post location

    bloc.town = _localStorage.getPostLocationData().postTown;
    bloc.city = _localStorage.getPostLocationData().postCity;
    bloc.district = _localStorage.getPostLocationData().postDistrict;

    bloc.getPosts();
  }
}
