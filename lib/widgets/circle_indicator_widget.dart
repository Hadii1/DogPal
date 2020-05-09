import 'package:flutter/material.dart';

class CircularIndicators extends StatelessWidget {
  const CircularIndicators({
    @required this.activeIndex,
    @required this.totalNumber,
  });
  final int totalNumber;
  final int activeIndex;
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalNumber, (i) {
          return Material(
            elevation: 2,
            color: Colors.transparent,
            shape: CircleBorder(),
            shadowColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: AnimatedContainer(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == activeIndex
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200]),
                duration: Duration(
                  milliseconds: 300,
                ),
                height: i == activeIndex ? 12 : 8,
                width: i == activeIndex ? 12 : 8,
                curve: Curves.easeOutQuad,
              ),
            ),
          );
        }).toList());
  }
}
