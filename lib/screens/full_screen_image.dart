import 'dart:typed_data';
import 'package:dog_pal/widgets/circle_indicator_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

class FullScreenView extends StatefulWidget {
  const FullScreenView({
    @required this.activePicture,
    this.assetList,
    this.urlsList,
    this.heroTag,
  });
  final List<Asset> assetList;
  final List<String> urlsList;
  final int activePicture;
  final String heroTag;

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
        onDismissed: (_) =>
            Navigator.of(context, rootNavigator: true).pop(_currentIndex),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.assetList == null
                /*/*/* For network images */*/*/
                ? _DogPhotoViews(
                    widget.urlsList,
                    initialImage: _currentIndex,
                    heroTag: widget.heroTag,
                    onChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  )

                /*/*/* For assets */*/*/
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: widget.assetList.map(
                      (asset) {
                        return PhotoView.customChild(
                            maxScale: PhotoViewComputedScale.contained * 2,
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained,
                            child: AssetMemoryImage(asset));
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
    );
  }
}

class _DogPhotoViews extends StatefulWidget {
  const _DogPhotoViews(
    this.urls, {
    this.initialImage,
    this.onChanged,
    this.heroTag,
  });
  final int initialImage;
  final List<String> urls;
  final Function(int) onChanged;
  final String heroTag;

  @override
  __DogPhotoViewsState createState() => __DogPhotoViewsState();
}

class __DogPhotoViewsState extends State<_DogPhotoViews> {
  int _currentIndex;
  PageController _controller;

  @override
  void initState() {
    _currentIndex = widget.initialImage ?? 0;
    _controller = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageGesturePageView.builder(
      controller: _controller,
      itemCount: widget.urls.length,
      onPageChanged: (index) {
        _currentIndex = index;
        widget.onChanged(index);
      },
      itemBuilder: (_, index) {
        String url = widget.urls[index];
        return Hero(
          tag: '$url${widget.heroTag}',
          child: ExtendedImage.network(
            url,
            fit: BoxFit.cover,
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
                        style: TextStyle(fontSize: ScreenUtil().setSp(38)),
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
