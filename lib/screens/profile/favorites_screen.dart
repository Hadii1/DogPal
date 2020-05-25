import 'dart:math';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/screens/adopt/adoption_dogs_list.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/screens/mate/mate_list.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/custom_animated_list.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:dog_pal/widgets/no_connection_widget.dart';
import 'package:dog_pal/widgets/unknown_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen();

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  ProfileBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<ProfileBloc>(context, listen: false);
    _bloc.adoptFavsScrollPos = 0;
    _bloc.dataStateStream.listen((state) {
      if (state == UserDataState.errorWithData) {
        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            _bloc.errorMsg,
            onRetry: () {
              if (mounted) {
                _bloc.initFavs();
              }
            },
            duration: Duration(seconds: 5),
          ),
        );
      }
    });

    _bloc.initFavs();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.adoptFavsScrollPos = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Adoption',
              ),
              Tab(
                text: 'Mating',
              ),
            ],
          ),
        ),
        body: StreamBuilder<UserDataState>(
          stream: _bloc.dataStateStream,
          initialData: _bloc.favs.isEmpty
              ? UserDataState.loadingWithNoData
              : UserDataState.loadingWithData,
          builder: (_, snapshot) {
            switch (snapshot.data) {
              case UserDataState.loadingWithNoData:
                return LoadingWidget();
                break;
              case UserDataState.loadingWithData:
                return _ListsWidget(
                  isLoading: true,
                );
                break;
              case UserDataState.postsReady:
                return _ListsWidget(
                  isLoading: false,
                );
                break;
              case UserDataState.errorWithNoData:
                return _bloc.errorMsg == GeneralConstants.NO_INTERNET_CONNECTION
                    ? NoInternetWidget(
                        onRetry: () => _bloc.initFavs(),
                      )
                    : UnknownErrorWidget(
                        onRetry: () => _bloc.initFavs(),
                      );
                break;

              case UserDataState.errorWithData:
                //A snackbar would be shown from error listener above
                return _ListsWidget(
                  isLoading: false,
                );
                break;

              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}

class _ListsWidget extends StatelessWidget {
  const _ListsWidget({@required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    ProfileBloc _bloc = Provider.of<ProfileBloc>(context, listen: false);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: isLoading
                ? SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(),
                  )
                : SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: TabBarView(
            children: <Widget>[
              _AdoptPostsWidget(
                bloc: _bloc,
              ),
              _MatePostsWidget(
                bloc: _bloc,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatePostsWidget extends StatelessWidget {
  _MatePostsWidget({
    @required this.bloc,
  });

  final ProfileBloc bloc;

  @override
  Widget build(BuildContext context) {
    final mateFavs = bloc.filterFavs(FavoriteType.mating);
    return mateFavs.isNotEmpty
        ? CustomAnimatedList(
            list: mateFavs,
            scrollPosition: bloc.mateFavsScrollPos,
            onScrollPositionChanged: (double nb) {
              bloc.mateFavsScrollPos = nb;
            },
            child: (index, key) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: MateCard(
                  post: mateFavs[index],
                  heroTag: 'favorites',
                  onDeletePressed: () =>
                      bloc.removeFromFavs(mateFavs[index].id),
                  onFavPressed: () {
                    key.currentState.removeItem(
                      index,
                      (_, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SizeTransition(
                            sizeFactor: anim,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: MateCard(
                                post: mateFavs[index],
                                heroTag: Random().nextInt(999).toString(),
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    bloc.removeFromFavs(mateFavs[index].id);
                  },
                ),
              );
            },
          )
        : EmptyPage(displayText: 'No favorites were added here');
  }
}

class _AdoptPostsWidget extends StatelessWidget {
  _AdoptPostsWidget({
    @required this.bloc,
  });

  final ProfileBloc bloc;

  Widget build(BuildContext context) {
    final List<DogPost> adoptFavs = bloc.filterFavs(FavoriteType.adoption);
    return adoptFavs.isNotEmpty
        ? CustomAnimatedList(
            list: adoptFavs,
            onScrollPositionChanged: (value) => bloc.adoptFavsScrollPos = value,
            scrollPosition: bloc.adoptFavsScrollPos,
            child: (int index, GlobalKey<AnimatedListState> key) {
              return AdoptCard(
                post: adoptFavs[index],
                heroTag: 'favorites',
                onDeletePressed: () => bloc.removeFromFavs(adoptFavs[index].id),
                onFavPressed: () {
                  key.currentState.removeItem(
                    index,
                    (_, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SizeTransition(
                          sizeFactor: anim,
                          child: AdoptCard(
                            post: adoptFavs[index],
                            heroTag: Random().nextInt(999).toString(),
                          ),
                        ),
                      );
                    },
                  );

                  bloc.removeFromFavs(adoptFavs[index].id);
                },
              );
            },
          )
        : EmptyPage(displayText: 'Nothing was found');
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({@required this.displayText});

  final String displayText;

  @override
  Widget build(BuildContext context) {
    return Fader(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              getRandomDogImage(),
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                displayText,
                style: TextStyle(
                  color: blackishColor,
                  fontSize: ScreenUtil().setSp(50),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
