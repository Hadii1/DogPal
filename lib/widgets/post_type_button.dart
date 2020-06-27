import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostTypeButton extends StatelessWidget {
  const PostTypeButton({@required this.onTypePressed});
  final Function(PostType) onTypePressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 24),
      child: SizedBox(
        height: 100.sp,
        child: OutlineButton(
          splashColor: Colors.transparent,
          onPressed: () => _showPostTypeSheet(context),
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
          highlightedBorderColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Searching for:  Lost Dogs',
            style: TextStyle(
              color: blackishColor,
              fontSize: 42.sp,
            ),
          ),
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
