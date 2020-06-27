import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({
    @required this.filterStream,
    @required this.filterSheet,
    @required this.onClearPressed,
    @required this.onNearbyPressed,
  });
  final Stream<int> filterStream;

  final Widget filterSheet;

  final Function onNearbyPressed;
  final Function onClearPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: filterStream,
      initialData: 0,
      builder: (_, snapshot) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 100.sp,
                    child: OutlineButton(
                      splashColor: Colors.transparent,
                      onPressed: () => _showFilterSheet(context),
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      highlightedBorderColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        snapshot.data == 0
                            ? 'Filter'
                            : 'Filters: ${snapshot.data}',
                        style: TextStyle(
                          color: blackishColor,
                          fontSize: ScreenUtil().setSp(42),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedCrossFade(
                      duration: Duration(milliseconds: 250),
                      crossFadeState: snapshot.data == 0
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SizedBox(
                        height: 100.sp,
                        child: OutlineButton(
                          splashColor: Colors.transparent,
                          onPressed: onClearPressed,
                          highlightedBorderColor:
                              Theme.of(context).primaryColor,
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: blackishColor,
                              fontSize: ScreenUtil().setSp(42),
                            ),
                          ),
                        ),
                      ),
                      secondChild: SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      elevation: 12,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14), topRight: Radius.circular(14))),
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return filterSheet;
      },
    );
  }
}
