import 'dart:math';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/navigators/dogs_screen_navigator.dart';
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

  int _bottomNavIndex = 0;

  AppBloc _appBloc;

  LocalStorage _localStorage;

  DogPostsBloc _dogPostsBloc;

  final List<String> _errorMsgs = [
    'Couldnt\'t add post. There seems to be an error from our side.',
    'Oops.. we couldn\'t add your post. Looks like somethings went wrong.',
    'We\'ve had an error adding your post.',
  ];

  @override
  void initState() {
    _appBloc = Provider.of<AppBloc>(context, listen: false);
    _localStorage = Provider.of<LocalStorage>(context, listen: false);
    _dogPostsBloc = Provider.of<DogPostsBloc>(context, listen: false);

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

    //Show any information from the decisions screen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (widget.locationNotification != null) {
          _scaffoldKey.currentState.showSnackBar(widget.locationNotification);
        }

        //Show first location:
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
              'Showing results in ${_localStorage.getUserLocationData().userDisplay}'),
        ));
      },
    );
    // TODO: refactor refreshing posts into bloc
    _appBloc.operationStatus.listen((status) {
      switch (status) {
        case OperationStatus.adding:
          _showProgressNotification();
          break;
        case OperationStatus.successful:
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _showSuccessNotification();
          _refreshPosts();
          break;
        case OperationStatus.failed:
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
      iconSize: 75.sp,
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

  void _navigateToPost(BuildContext context) {
    Widget child;

    switch (_appBloc.dogPost.type) {
      case 'lost':
        child = LostDogDetailsScreen(
          LostDetailsArgs(
            post: _appBloc.dogPost,
          ),
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
    //to search for the last post added we edit the
    //location we're searching in to the last post location

    _dogPostsBloc.town = _localStorage.getPostLocationData().postTown;
    _dogPostsBloc.city = _localStorage.getPostLocationData().postCity;
    _dogPostsBloc.district = _localStorage.getPostLocationData().postDistrict;

    PostType type;
    //check last post type we added to query for this type
    switch (_appBloc.dogPost.type) {
      case 'lost':
        type = PostType.lost;
        break;
      case 'adopt':
        type = PostType.adopt;
        break;
      case 'mate':
        type = PostType.mate;
        break;
      default:
        throw PlatformException(code: 'post type not supported');
    }

    _dogPostsBloc.onPostTypeChanded(type);

    _dogPostsBloc.getPosts();
  }
}
