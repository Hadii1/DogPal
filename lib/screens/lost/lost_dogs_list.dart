import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/navigators/lost_navigator.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LostList extends StatelessWidget {
  const LostList({
    @required this.scrollController,
    @required this.posts,
    @required this.onRefresh,
  });

  final ScrollController scrollController;
  final List posts;
  final Function onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      height: double.maxFinite,
      child: RefreshIndicator(
        onRefresh: () => onRefresh(),
        child: Scrollbar(
          child: AnimationLimiter(
            child: ListView.builder(
              controller: scrollController,
              itemCount: posts.length,
              itemBuilder: (_, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    verticalOffset: 150,
                    duration: Duration(milliseconds: 300),
                    child: FadeInAnimation(
                      duration: Duration(milliseconds: 250),
                      child: Column(
                        children: <Widget>[
                          LostPostCard(
                            post: posts[index],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 40),
                            child: Divider(
                              height: 1,
                              thickness: 0.2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class LostPostCard extends StatelessWidget {
  const LostPostCard({
    @required this.post,
    this.onDeletePressed,
  });
  final LostPost post;
  final Function onDeletePressed;
  @override
  Widget build(BuildContext context) {
    final _cardHeight = MediaQuery.of(context).size.height * 0.24;
    return Container(
      padding: const EdgeInsets.all(8),
      height: _cardHeight,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          LostRoutes.LOST_DOG_DETAILS_SCREEN,
          arguments: LostDetailsArgs(
            post: post,
            onDeletePressed: onDeletePressed,
            bloc: Provider.of<LostBloc>(context, listen: false),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            /*/*/* Dog Image */*/*/

            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: SizedBox.expand(
                    child: Hero(
                        tag: '${post.dog.imagesUrls[0]}null',
                        transitionOnUserGestures: true,
                        placeholderBuilder: (c, s, w) {
                          return ExtendedImage.network(
                            post.dog.imagesUrls[0],
                            fit: BoxFit.cover,
                          );
                        },
                        child: ExtendedImage.network(
                          post.dog.imagesUrls[0],
                          fit: BoxFit.cover,
                          loadStateChanged: (ExtendedImageState state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                                return Container(
                                  color: Colors.grey[200],
                                  child: Shimmer.fromColors(
                                    child: Card(
                                      child: SizedBox.expand(),
                                    ),
                                    baseColor: Colors.grey[200],
                                    highlightColor: Colors.white,
                                  ),
                                );
                                break;

                              case LoadState.completed:
                                return null;
                                break;

                              case LoadState.failed:
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Text(
                                      'Loading Failed',
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(38)),
                                    ),
                                  ),
                                );
                                break;
                              default:
                                return null;
                            }
                          },
                        )),
                  ),
                ),
              ),
            ),

            /*/*/* Dog Info */*/*/

            Flexible(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                child: Stack(
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.dog.dogName,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(65),
                              color: blackishColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          post.dog.breed != null && post.dog.breed.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 24),
                                  child: Text(
                                    post.dog.breed,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(46),
                                    ),
                                  ),
                                )
                              : Container(),
                        ]),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        getTimeDifference(post.dateAdded),
                        softWrap: true,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
