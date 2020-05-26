import 'dart:io';

import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/screens/adopt/adoption_dogs_list.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/screens/lost/lost_dogs_list.dart';
import 'package:dog_pal/screens/mate/mate_list.dart';
import 'package:dog_pal/screens/profile/favorites_screen.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/no_connection_widget.dart';
import 'package:dog_pal/widgets/unknown_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen();

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  ProfileBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<ProfileBloc>(context, listen: false);
    _bloc.dataStateStream.listen((state) {
      if (state == UserDataState.errorWithData) {
        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            _bloc.errorMsg,
            onRetry: () {
              if (mounted) {
                _bloc.initUserPosts();
              }
            },
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
    _bloc.initUserPosts();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Posts',
            style: TextStyle(fontSize: 65.sp),
          ),
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              size: 75.sp,
              color: blackishColor,
            ),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Lost',
              ),
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
          initialData: _bloc.userPosts.isEmpty
              ? UserDataState.loadingWithNoData
              : UserDataState.loadingWithNoData,
          builder: (_, snapshot) {
            switch (snapshot.data) {
              case UserDataState.loadingWithNoData:
                return LoadingWidget();
                break;
              case UserDataState.loadingWithData:
                return PostsBody(
                  isLoading: true,
                );
                break;
              case UserDataState.postsReady:
                return PostsBody(
                  isLoading: false,
                );
                break;
              case UserDataState.errorWithNoData:
                return _bloc.errorMsg == GeneralConstants.NO_INTERNET_CONNECTION
                    ? NoInternetWidget(
                        onRetry: () => _bloc.initUserPosts(),
                      )
                    : UnknownErrorWidget(
                        onRetry: () => _bloc.initUserPosts(),
                      );
                break;

              case UserDataState.errorWithData:
                return PostsBody(
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

class PostsBody extends StatelessWidget {
  const PostsBody({@required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    ProfileBloc bloc = Provider.of<ProfileBloc>(context, listen: false);
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
              LostWidget(
                posts: bloc.filterPosts('lost'),
              ),
              AdoptWidget(
                adoptPosts: bloc.filterPosts('adopt'),
              ),
              MateWidget(
                matePosts: bloc.filterPosts('mate'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LostWidget extends StatelessWidget {
  const LostWidget({
    @required this.posts,
  });

  final List<DogPost> posts;

  @override
  Widget build(BuildContext context) {
    return posts.isNotEmpty
        ? AnimationLimiter(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (_, index) {
                  return AnimationConfiguration.staggeredList(
                    delay: Duration(milliseconds: 50),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 100,
                      duration: Duration(milliseconds: 200),
                      child: LostPostCard(
                        post: posts[index],
                        onDeletePressed: () =>
                            Provider.of<ProfileBloc>(context, listen: false)
                                .updatePostsList(posts[index].id),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : EmptyPage(displayText: 'No posts added');
  }
}

class MateWidget extends StatelessWidget {
  const MateWidget({@required this.matePosts});

  final List<MatePost> matePosts;

  @override
  Widget build(BuildContext context) {
    return matePosts.isNotEmpty
        ? Scrollbar(
            child: AnimationLimiter(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: matePosts.length,
                  itemBuilder: (_, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      delay: Duration(milliseconds: 150),
                      child: SlideAnimation(
                        duration: Duration(milliseconds: 200),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: MateCard(
                            post: matePosts[index],
                            onDeletePressed: () =>
                                Provider.of<ProfileBloc>(context, listen: false)
                                    .updatePostsList(matePosts[index].id),
                            heroTag: 'posts',
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          )
        : EmptyPage(displayText: 'No posts added');
  }
}

class AdoptWidget extends StatelessWidget {
  AdoptWidget({
    @required this.adoptPosts,
  });

  final List<DogPost> adoptPosts;

  @override
  Widget build(BuildContext context) {
    return adoptPosts.isNotEmpty
        ? AnimationLimiter(
            child: Scrollbar(
              child: ListView.builder(
                  itemCount: adoptPosts.length,
                  itemBuilder: (_, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        duration: Duration(milliseconds: 250),
                        verticalOffset: 60,
                        child: AdoptCard(
                          post: adoptPosts[index],
                          onDeletePressed: () =>
                              Provider.of<ProfileBloc>(context, listen: false)
                                  .updatePostsList(adoptPosts[index].id),
                          heroTag: 'posts',
                        ),
                      ),
                    );
                  }),
            ),
          )
        : EmptyPage(displayText: 'No posts added');
  }
}
