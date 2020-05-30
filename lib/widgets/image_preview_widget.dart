import 'dart:io';

import 'package:dog_pal/screens/full_screen_image.dart';
import 'package:dog_pal/widgets/circle_indicator_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview(
    this.urlsList, {
    this.height,
    this.onPressed,
    this.initialImage,
    this.onChanged,
    this.showIndicator,
    this.heroTag,
  });

  final double height;
  final String heroTag;
  final int initialImage;
  final bool showIndicator;
  final List<String> urlsList;
  final Function(int) onPressed;
  final Function(int) onChanged;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  int _activeIndex;
  bool _showIndicator;
  PageController _controller;

  @override
  void initState() {
    _showIndicator = widget.showIndicator ?? true;
    _activeIndex = widget.initialImage ?? 0;
    _controller = PageController(initialPage: _activeIndex);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _height = widget.height ?? MediaQuery.of(context).size.height * 0.6;
    return Container(
      height: _height,
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: widget.urlsList.length,
            controller: _controller,
            onPageChanged: (int i) {
              setState(
                () {
                  _activeIndex = i;
                  if (widget.onChanged != null) {
                    widget.onChanged(_activeIndex);
                  }
                },
              );
            },
            itemBuilder: (_, index) {
              return Container(
                width: double.maxFinite,
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    if (widget.onPressed == null) {
                      _navigateToFullScreenImage();
                    } else {
                      widget.onPressed(index);
                    }
                  },
                  child: Hero(
                    tag: '${widget.urlsList[index]}${widget.heroTag}',
                    transitionOnUserGestures: true,
                    placeholderBuilder: (context, heroSize, child) =>
                        ExtendedImage.network(
                      widget.urlsList[index],
                      fit: BoxFit.cover,
                    ),
                    child: Container(
                      color: Colors.black,
                      child: ExtendedImage.network(
                        widget.urlsList[index],
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
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Index Circular Indicator
          _showIndicator
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: CircularIndicators(
                    activeIndex: _activeIndex,
                    totalNumber: widget.urlsList.length,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  void _navigateToFullScreenImage() {
    Widget child = FullScreenView(
      activePicture: _activeIndex,
      urlsList: widget.urlsList,
      heroTag: widget.heroTag,
      onChanged: (index) {
        setState(() {
          _activeIndex = index;
          _controller.jumpToPage(_activeIndex);
        });
      },
    );
    Navigator.of(context, rootNavigator: true).push(
      Platform.isIOS
          ? TransparentRoute(builder: () => child)
          : TransparentMaterialPageRoute(builder: (_) => child),
    );
  }
}

class TransparentRoute extends PageRoute {
  TransparentRoute({@required this.builder});
  final Widget Function() builder;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: builder(),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 400);
}
