import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostTypeField extends StatelessWidget {
  const PostTypeField({
    @required this.onTypePressed,
    @required this.type,
  });
  final Function(PostType) onTypePressed;
  final Stream<String> type;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 24),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _showPostTypeSheet(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Searching for: ',
              style: TextStyle(
                color: blackishColor,
                fontFamily: 'Montserrat',
                fontSize: 54.sp,
              ),
            ),
            Expanded(
              child: StreamBuilder<String>(
                stream: type,
                initialData: 'Adoption Dogs',
                builder: (context, snapshot) {
                  return Row(
                    children: <Widget>[
                      Text(
                        ' ${snapshot.data}',
                        style: TextStyle(
                          color: blackishColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                          fontSize: 54.sp,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showPostTypeSheet(BuildContext context) {
    showCupertinoModalPopup(
      useRootNavigator: true,
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            isDefaultAction: true,
          ),
          title: Text(
            'Post Type',
            style: TextStyle(fontSize: 65.sp),
          ),
          message: Text(
            'What are you searching for?',
            style: TextStyle(fontSize: 45.sp),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                onTypePressed(PostType.lost);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                'Lost Dogs',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                onTypePressed(PostType.mate);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                'Mating Dogs',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                onTypePressed(PostType.adopt);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                'Adoption Dogs',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
