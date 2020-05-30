import 'dart:async';
import 'dart:typed_data';
import 'package:dog_pal/widgets/circle_indicator_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenView extends StatefulWidget {
  const FullScreenView({
    @required this.activePicture,
    @required this.onChanged,
    this.assetList,
    this.urlsList,
    this.heroTag,
  });
  final List<Asset> assetList;
  final List<String> urlsList;
  final int activePicture;
  final String heroTag;
  final Function(int) onChanged;

  @override
  _FullScreenViewState createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  PageController _pageController;
  int _currentIndex;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.activePicture ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Dismissible(
        key: _key,
        direction: DismissDirection.down,
        onDismissed: (_) => Navigator.of(context, rootNavigator: true).pop(),
        child: ColorChanger(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              widget.assetList == null
                  ?
                  /*/*/* For network images */*/*/
                  ExtendedImageGesturePageView.builder(
                      controller: _pageController,
                      itemCount: widget.urlsList.length,
                      onPageChanged: (index) {
                        _currentIndex = index;
                        widget.onChanged(index);
                      },
                      itemBuilder: (_, index) {
                        String url = widget.urlsList[index];
                        return Hero(
                          transitionOnUserGestures: true,
                          tag: '$url${widget.heroTag}',
                          child: ExtendedImage.network(
                            url,
                            fit: BoxFit.contain,
                            mode: ExtendedImageMode.gesture,
                            initGestureConfigHandler: (state) {
                              return GestureConfig(
                                cacheGesture: false,
                                minScale: 1,
                                animationMinScale: 0.7,
                                maxScale: 3.0,
                                animationMaxScale: 3.5,
                                speed: 1.0,
                                inertialSpeed: 100.0,
                                initialScale: 1.0,
                                inPageView: true,
                                initialAlignment: InitialAlignment.center,
                              );
                            },
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Center(
                                    child: CircularProgressIndicator(),
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
                        );
                      },
                    )
                  :

                  /*/*/* For assets */*/*/
                  PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          widget.onChanged(_currentIndex);
                        });
                      },
                      children: widget.assetList.map(
                        (asset) {
                          return PhotoView.customChild(
                            maxScale: PhotoViewComputedScale.contained * 2,
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained,
                            child: AssetMemoryImage(asset),
                          );
                        },
                      ).toList(),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true)
                        .pop(_currentIndex),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularIndicators(
                    activeIndex: _currentIndex,
                    totalNumber: widget.urlsList == null
                        ? widget.assetList.length
                        : widget.urlsList.length,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AssetMemoryImage extends StatefulWidget {
  const AssetMemoryImage(this.asset);
  final Asset asset;

  @override
  _AssetMemoryImageState createState() => _AssetMemoryImageState();
}

class _AssetMemoryImageState extends State<AssetMemoryImage> {
  bool _isLoading = true;
  Uint8List data;

  @override
  void initState() {
    _getImageData();
    super.initState();
  }

  Future<Uint8List> _getImageData() async {
    ByteData byteData = await widget.asset.getByteData();
    data = byteData.buffer.asUint8List();
    setState(() {
      _isLoading = false;
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 150),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : data == null
                ? Container()
                : Image.memory(
                    data,
                    fit: BoxFit.contain,
                  ),
      ),
    );
  }
}

class ColorChanger extends StatefulWidget {
  ColorChanger({@required this.child});
  final Widget child;

  @override
  _ColorChangerState createState() => _ColorChangerState();
}

class _ColorChangerState extends State<ColorChanger> {
  bool _changeColor = false;
  @override
  void initState() {
    super.initState();

    Timer(
      Duration(milliseconds: 50),
      () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              setState(() {
                _changeColor = true;
              });
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      color: _changeColor ? Colors.black : Colors.transparent,
      child: widget.child,
    );
  }
}
