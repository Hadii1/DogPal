import 'dart:io';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/sentry_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class MateList extends StatelessWidget {
  const MateList({
    @required this.posts,
    @required this.onRetry,
    @required this.pageController,
    this.onFavPressed,
  });

  final List<MatePost> posts;
  final Function onRetry;
  final Function onFavPressed;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      height: double.maxFinite,
      child: RefreshIndicator(
        onRefresh: onRetry,
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 52),
            child: AnimationLimiter(
              child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                itemBuilder: (_, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      duration: Duration(milliseconds: 300),
                      verticalOffset: 150,
                      child: FadeInAnimation(
                        duration: Duration(milliseconds: 250),
                        child: MateCard(
                          post: posts[index],
                          onFavPressed: onFavPressed,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MateCard extends StatefulWidget {
  const MateCard({
    @required this.post,
    this.onFavPressed,
    this.onDeletePressed,
    this.heroTag,
  });
  final MatePost post;
  final Function onFavPressed;
  final Function onDeletePressed;
  final String heroTag;

  @override
  _MateCardState createState() => _MateCardState();
}

class _MateCardState extends State<MateCard> {
  LocalStorage _localStorage;
  @override
  void initState() {
    _localStorage = Provider.of<LocalStorage>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: <Widget>[
            ImagePreview(
              widget.post.dog.imagesUrls,
              height: double.maxFinite,
              heroTag: widget.heroTag,
              showIndicator: false,
              onPressed: (int index) => Navigator.of(context).pushNamed(
                MateRoutes.MATE_DOG_WALL,
                arguments: MateDetailsArgs(
                  post: widget.post,
                  onDeletePressed: widget.onDeletePressed,
                  activeImageIndex: index,
                  heroTag: widget.heroTag,
                  bloc: Provider.of<MateBloc>(context, listen: false),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, 0.4],
                    colors: [
                      Colors.transparent,
                      blackishColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.post.dog.dogName,
                              style: TextStyle(
                                letterSpacing: 0.4,
                                color: yellowishColor,
                                fontFamily: 'Montserrat',
                                fontSize: 75.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            widget.post.dog.breed != null &&
                                    widget.post.dog.breed.isNotEmpty
                                ? Text(
                                    widget.post.dog.breed,
                                    style: TextStyle(
                                      color: yellowishColor,
                                      fontSize: 60.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat',
                                    ),
                                  )
                                : SizedBox.shrink()
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          try {
                            //Save locally
                            _localStorage.toggleFavorites(
                              widget.post.id,
                              FavoriteType.mating,
                            );

                            //update the local and online user object with the new favs list

                            User user = _localStorage.getUser();

                            user.favMatingPost =
                                _localStorage.getFavorites(FavoriteType.mating);

                            _localStorage.editUser(user);

                            setState(() {}); // to animate the icon

                            //Save to network
                            if (_localStorage.isAuthenticated()) {
                              FirestoreService().saveUserFavs(
                                  userId: user.uid,
                                  mateFavs: user.favMatingPost);
                            }

                            if (widget.onFavPressed != null) {
                              widget.onFavPressed();
                            }
                          } on PlatformException catch (e, s) {
                            sentry.captureException(
                                exception: e, stackTrace: s);
                          } on SocketException {
                            Scaffold.of(context).showSnackBar(
                              errorSnackBar('Poor Internet Connection'),
                            );
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: _localStorage
                                  .getFavorites(FavoriteType.mating)
                                  .contains(widget.post.id)
                              ? Container(
                                  child: Icon(
                                    Icons.favorite,
                                    color: Theme.of(context).primaryColor,
                                    size: 30,
                                  ),
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: yellowishColor,
                                  size: 30,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
