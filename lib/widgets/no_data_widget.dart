import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'fade_in_widget.dart';

class NoDogsWidget extends StatelessWidget {
  const NoDogsWidget({
    @required this.postType,
    @required this.filters,
  });
  final PostType postType;
  final int filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Fader(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No results',
                    style: TextStyle(
                      color: blackishColor,
                      fontSize: ScreenUtil().setSp(75),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                    child: Text(
                      _getText(),
                      softWrap: true,
                      style: TextStyle(
                        color: blackishColor,
                        fontSize: ScreenUtil().setSp(55),
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
              ),
              _getImage()
            ],
          ),
        ),
      ),
    );
  }

  Image _getImage() {
    switch (postType) {
      case PostType.lost:
        return Image.asset('assets/man_with_many_dogs.png');
        break;
      case PostType.adopt:
        return Image.asset('assets/dog_with_woman.png');
        break;
      case PostType.mate:
        return Image.asset('assets/dog_smelling.png');
        break;
      default:
        return null;
    }
  }

  String _getText() {
    if (filters != 0) {
      return 'Try tweaking your filters';
    } else {
      if (postType == PostType.lost) {
        return 'Gladly, there\'s no lost dogs here';
      } else {
        return 'Try another city';
      }
    }
  }
}
