import 'package:flutter/material.dart';

class Fader extends StatefulWidget {
  const Fader({this.child});
  final Widget child;
  @override
  _FaderState createState() => _FaderState();
}

class _FaderState extends State<Fader> {
  bool _shouldShow = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _shouldShow = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: _shouldShow ? 1 : 0,
      child: widget.child,
    );
  }
}

