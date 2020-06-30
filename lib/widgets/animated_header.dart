import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedHeader extends StatefulWidget {
  AnimatedHeader({
    @required this.child,
    @required this.didPressSuggestion,
    @required this.scrollController,
  });
  final ScrollController scrollController;
  final Stream<bool> didPressSuggestion;
  final Widget child;

  @override
  _AnimatedHeaderState createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader> {
  bool _shouldShow = true;

  @override
  void initState() {
    super.initState();

    widget.didPressSuggestion.listen((_) {
      if (mounted) {
        setState(() {
          _shouldShow = true;
        });
      }
    });

    widget.scrollController.addListener(() {
      if (mounted) {
        if (widget.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _shouldShow = false;
        } else {
          _shouldShow = true;
        }

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: _shouldShow ? 230.sp : 0,
      duration: Duration(milliseconds: 200),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 150),
        opacity: _shouldShow ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
