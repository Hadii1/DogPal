import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/navigators/dogs_screen_navigator.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:provider/provider.dart';

import 'adoption_dog_details.dart';

class AdoptionList extends StatelessWidget {
  const AdoptionList({
    @required this.posts,
    @required this.scrollController,
    @required this.onRefresh,
    @required this.onFavPressed,
  });

  final List<AdoptPost> posts;
  final ScrollController scrollController;
  final Function onRefresh;
  final Function(AdoptPost post) onFavPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      height: double.maxFinite,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: Scrollbar(
          child: AnimationLimiter(
            child: ListView.builder(
              controller: scrollController,
              itemCount: posts.length,
              itemBuilder: (_, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    verticalOffset: 150,
                    duration: Duration(milliseconds: 300),
                    child: FadeInAnimation(
                      duration: Duration(milliseconds: 250),
                      child: AdoptCard(
                        post: posts[index],
                        onFavPressed: onFavPressed,
                        heroTag: 'widgetToShowWhileAnimating',
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

class AdoptCard extends StatefulWidget {
  const AdoptCard({
    @required this.post,
    @required this.onFavPressed,
    this.onDeletePressed,
    this.heroTag,
  });
  final AdoptPost post;
  final Function(AdoptPost post) onFavPressed;
  final Function onDeletePressed;
  final String heroTag;
/*/*/*  The heroTag is used because this widget is used more than once
 in the same subtree and we expect the hero animation so we need
  to identify a different tag according to the place of the widget */*/*/

  @override
  _AdoptCardState createState() => _AdoptCardState();
}

class _AdoptCardState extends State<AdoptCard> {
  int _imageScrollIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _localStorage = Provider.of<LocalStorage>(context, listen: false);
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ImagePreview(
                      widget.post.dog.imagesUrls,
                      heroTag: widget.heroTag,
                      initialImage: _imageScrollIndex,
                      onPressed: (int index) => Navigator.of(context).pushNamed(
                        DogsScreenRoutes.ADOPTION_DOG_WALL,
                        arguments: AdoptDetailsArgs(
                          post: widget.post,
                          activeImageIndex: index,
                          heroTag: widget.heroTag,
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.35,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              widget.onFavPressed(widget.post);
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: _localStorage
                                    .getFavorites(FavoriteType.adoption)
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
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8),
                  child: Text(
                    widget.post.dog.dogName,
                    style: TextStyle(
                      color: blackishColor,
                      letterSpacing: 0.5,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      fontSize: ScreenUtil().setSp(72),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.post.dog.breed,
                    style: TextStyle(
                      color: blackishColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                      fontSize: ScreenUtil().setSp(52),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
