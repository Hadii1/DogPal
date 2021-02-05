import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

//Used in user favs
class CustomAnimatedList extends StatefulWidget {
  const CustomAnimatedList({
    @required this.list,
    this.onScrollPositionChanged,
    @required this.scrollPosition,
    @required this.child,
  });
  final List<DogPost> list;
  final Function(
    double,
  ) onScrollPositionChanged;
  final Widget Function(int, GlobalKey<AnimatedListState>) child;
  final double scrollPosition;

  @override
  _CustomAnimatedListState createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  ScrollController _scrollController;
  GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController(initialScrollOffset: widget.scrollPosition);

    _scrollController.addListener(() {
      if (mounted) {
        widget.onScrollPositionChanged(_scrollController.position.pixels);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Scrollbar(
        child: AnimatedList(
          initialItemCount: widget.list.length,
          key: _listKey,
          controller: _scrollController,
          itemBuilder: (_, index, animation) {
            return AnimationConfiguration.staggeredList(
              position: index,
              child: FadeInAnimation(
                duration: Duration(milliseconds: 220),
                child: SlideAnimation(
                  duration: Duration(milliseconds: 300),
                  verticalOffset: 150,
                  child: widget.child(index, _listKey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
