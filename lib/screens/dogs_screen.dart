import 'dart:math';
import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/navigators/adopt_navigator.dart';
import 'package:dog_pal/navigators/lost_navigator.dart';
import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/screens/adopt/adoption_dogs_list.dart';
import 'package:dog_pal/screens/filter_pages.dart';
import 'package:dog_pal/screens/lost/lost_dogs_list.dart';
import 'package:dog_pal/screens/mate/mate_list.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/animated_header.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:dog_pal/widgets/filter_buttons_widget.dart';
import 'package:dog_pal/widgets/location_access_denied.dart';
import 'package:dog_pal/widgets/location_search_bar.dart';
import 'package:dog_pal/widgets/no_connection_widget.dart';
import 'package:dog_pal/widgets/no_data_widget.dart';
import 'package:dog_pal/widgets/unknown_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class DogsScreen extends StatefulWidget {
  const DogsScreen({@required this.postType});
  final PostType postType;

  @override
  _DogsScreenState createState() => _DogsScreenState();
}

class _DogsScreenState extends State<DogsScreen> {
  DogPostsBloc _bloc;

  PostType get _state => widget.postType;

  bool _showUpperSnackbar = false;

  @override
  void initState() {
    _initializeBloc();
    _bloc.blocNotifications.listen((notification) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notification,
            style: TextStyle(
              fontSize: 45.sp,
            ),
          ),
        ),
      );
    });
    _bloc.getPosts();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        //So that the keyboard hides when the user taps anywhere outside
        onTap: () {
          FocusScopeNode node = FocusScope.of(context);
          if (!node.hasPrimaryFocus) {
            node.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: AnimatedHeader(
            height: 150.sp,
            scrollController: _bloc.pageController,
            didPressSuggestion: _bloc.isSuggestionPressed,
            child: FloatingActionButton(
              tooltip: 'Add Post',
              heroTag: Random().nextInt(999),
              child: Icon(
                Icons.add,
              ),
              onPressed: _handleFabPress,
            ),
          ),
          body: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(21, 4, 21, 0),
                    child: LocationSeachBar(
                      cityController: _bloc.cityNameController,
                      onSuggestionSelected: (town, city, district, display) {
                        _bloc.town = town;
                        _bloc.city = city;
                        _bloc.district = district;
                        _bloc.onSuggestionSelected();
                        _bloc.getPosts();
                      },
                    ),
                  ),
                  AnimatedHeader(
                    didPressSuggestion: _bloc.isSuggestionPressed,
                    scrollController: _bloc.pageController,
                    child: FilterButtons(
                      filterSheet: _handleFilterSheet(),
                      onClearPressed: _bloc.clearFilters,
                      onNearbyPressed: _bloc.nearByPressed,
                      filterStream: _bloc.activeFilters,
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<DataState>(
                      stream: _bloc.dataState,
                      initialData: DataState.loading,
                      builder: (_, AsyncSnapshot snapshot) {
                        switch (snapshot.data) {
                          case DataState.loading:
                            return LoadingWidget();
                            break;

                          case DataState.networkError:
                            return NoInternetWidget(
                              onRetry: () => _bloc.getPosts(),
                            );
                            break;

                          case DataState.locationServiceOff:
                            return LocationServiceOff();
                            break;

                          case DataState.locationDenied:
                            return LocationAccessDenied();
                            break;

                          case DataState.unknownError:
                            return UnknownErrorWidget(
                              onRetry: () => _bloc.getPosts(),
                            );
                            break;

                          case DataState.locationUnknownError:
                            return UnknownErrorWidget(
                              onRetry: () => _bloc.nearByPressed(),
                            );

                          case DataState.locationNetworkError:
                            return NoInternetWidget(
                              onRetry: () => _bloc.nearByPressed(),
                            );
                            break;

                          case DataState.postsAvailable:
                            return getPostsList();
                            break;

                          case DataState.noDataAvailable:
                            return NoDogsWidget(
                              postType: _state,
                              filters: _bloc.filters,
                            );
                            break;

                          default:
                            print(snapshot.data.toString());
                            return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                    begin: Offset(0, -1),
                    end: Offset(0, 0),
                  ).animate(animation),
                ),
                child: _showUpperSnackbar
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Material(
                              elevation: 12,
                              borderRadius: BorderRadius.circular(22),
                              color: blackishColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          'Another post is currently being added, kindly hold up until it finishes to add another one.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 0.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showUpperSnackbar = false;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              )),
                        ),
                      )
                    : SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleFilterSheet() {
    switch (_state) {
      case PostType.adopt:
        return AdoptFilterSheet(_bloc);
        break;
      case PostType.lost:
        return LostFilterPage(_bloc);
        break;
      case PostType.mate:
        return MateFilterPage(_bloc);
        break;
      default:
        return null;
    }
  }

  _handleFabPress() async {
    final AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
    final LocalStorage localStorage =
        Provider.of<LocalStorage>(context, listen: false);

    if (localStorage.isAuthenticated()) {
      if (!appBloc.currentlyAdding) {
        String destination;
        switch (_state) {
          case PostType.adopt:
            destination = AdoptRoutes.ADD_ADOPTION_POST;
            break;

          case PostType.lost:
            destination = LostRoutes.ADD_LOST_DOG;
            break;

          case PostType.mate:
            destination = MateRoutes.MATE_WARNING;
            break;
        }
        Navigator.of(context).pushNamed(destination);
      } else {
        if (mounted) {
          setState(() {
            _showUpperSnackbar = true;
          });
        }

        await Future.delayed(Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showUpperSnackbar = false;
            });
          }
        });
      }
    } else {
      Scaffold.of(context).showSnackBar(signInSnackBar(context));
    }
  }

  void _initializeBloc() {
    switch (_state) {
      case PostType.adopt:
        _bloc = Provider.of<AdoptBloc>(context, listen: false);
        break;
      case PostType.lost:
        _bloc = Provider.of<LostBloc>(context, listen: false);
        break;
      case PostType.mate:
        _bloc = Provider.of<MateBloc>(context, listen: false);
        break;
    }
  }

  Widget getPostsList() {
    Widget widget;
    switch (_state) {
      case PostType.adopt:
        widget = AdoptionList(
          posts: _bloc.posts,
          scrollController: _bloc.pageController,
          onRefresh: _bloc.getPosts,
          onFavPressed: (AdoptPost post) => _bloc.onFavoritePressed(post),
        );

        break;

      case PostType.mate:
        widget = MateList(
          posts: _bloc.posts,
          pageController: _bloc.pageController,
          onRetry: _bloc.getPosts,
          onFavPressed: (MatePost post) => _bloc.onFavoritePressed(post),
        );
        break;

      case PostType.lost:
        widget = LostList(
          posts: _bloc.posts,
          scrollController: _bloc.pageController,
          onRefresh: _bloc.getPosts,
        );
        break;

      default:
        widget = null;
    }

    return widget;
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Fader(
        child: Container(
          color: yellowishColor,
          child: Center(
            child: SpinKitThreeBounce(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
