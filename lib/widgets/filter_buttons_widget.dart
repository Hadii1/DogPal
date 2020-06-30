import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/screens/filter_pages.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({
    @required this.filterStream,
    @required this.onClearPressed,
  });

  final Stream<int> filterStream;
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
                        borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.only(left: 6),
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
                            borderRadius: BorderRadius.circular(12),
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
      // backgroundColor: Color(0xC7F9F9F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        Widget filterSheet;
        DogPostsBloc bloc = Provider.of<DogPostsBloc>(context, listen: false);
        switch (bloc.postsType) {
          case PostType.lost:
            filterSheet = LostFilterPage(bloc);
            break;
          case PostType.adopt:
            filterSheet = AdoptFilterSheet(bloc);
            break;
          case PostType.mate:
            filterSheet = MateFilterPage(bloc);
            break;
        }
        return filterSheet;
      },
    );
  }
}
