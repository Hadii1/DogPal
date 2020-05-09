import 'dart:io';

import 'package:dog_pal/screens/full_screen_image.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSlide extends StatefulWidget {
  const ImageSlide({
    @required this.allowedPhotos,
    @required this.initalPhotos,
    @required this.onChanged,
  });

  final int allowedPhotos;
  final List<Asset> initalPhotos;
  final Function(List<Asset>) onChanged;

  @override
  _ImageSlideState createState() => _ImageSlideState();
}

class _ImageSlideState extends State<ImageSlide> {
  List<Asset> get _initialAssets => widget.initalPhotos;

  int get _allowed => widget.allowedPhotos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.24,
      child: GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          /*/*/*/* Actual Images */*/*/*/

          ...List.generate(widget.initalPhotos.length, (int index) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      color: Colors.grey[300],
                      child: InkWell(
                        onTap: () {
                          _navigateToPreview(
                            index,
                            widget.initalPhotos,
                          );
                        },
                        child: Center(
                          child: AssetThumb(
                            asset: widget.initalPhotos[index],
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Delete image icon

                  Container(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        _initialAssets.removeAt(index);
                        setState(() {});
                        widget.onChanged(_initialAssets);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),

          /*/*/*/* Image PlaceHolders */*/*/*/

          ...List.generate(
            _allowed - _initialAssets.length,
            (index) {
              return InkWell(
                onTap: () => _addImages(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: blackishColor, width: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _navigateToPreview(int activePicture, List<Asset> list) {
    Navigator.of(context, rootNavigator: true).push(
      TransparentMaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullScreenView(
          activePicture: activePicture,
          assetList: list,
        ),
      ),
    );
  }

  _addImages() async {
    List<Asset> list = List();

    try {
      Permission permission =
          Platform.isIOS ? Permission.photos : Permission.storage;

      bool isGranted = await checkAndAskPermission(permission: permission);
      if (isGranted) {
        list = await MultiImagePicker.pickImages(
            maxImages: _allowed - _initialAssets.length);

        setState(() {
          _initialAssets.addAll(list);

          widget.onChanged(_initialAssets);
        });
      } else {
        Scaffold.of(context).showSnackBar(permissionSnackbar(
            'Access to photos was denied',
            androidPermission: Permission.storage));
      }
    } on PlatformException catch (e) {
      print(e.code ?? e.message);
      Scaffold.of(context).showSnackBar(
        errorSnackBar('Something went wrong'),
      );
    } on NoImagesSelectedException {}
  }
}
