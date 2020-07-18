import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostTypeField extends StatelessWidget {
  const PostTypeField({
    @required this.onTypePressed,
    @required this.type,
    @required this.location,
    @required this.initialLocation,
    @required this.intialType,
  });
  final Function(PostType) onTypePressed;
  final Stream<String> type;
  final Stream<String> location;
  final String intialType;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 12),
      child: StreamBuilder<String>(
        stream: location,
        initialData: initialLocation,
        builder: (_, locationSnapshot) {
          return StreamBuilder<String>(
            stream: type,
            initialData: intialType,
            builder: (_, typeSnapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: blackishColor,
                          fontFamily: 'Montserrat',
                          fontSize: 52.sp,
                        ),
                        children: [
                          TextSpan(text: 'Showing '),
                          TextSpan(
                            text: typeSnapshot.data,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _showPostTypeSheet(context),
                          ),
                          TextSpan(text: ' in '),
                          TextSpan(text: locationSnapshot.data),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                ],
              );
            },
          );
        },
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
