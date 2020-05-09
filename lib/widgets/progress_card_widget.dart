import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard(this.shouldLoad);
  final Stream<bool> shouldLoad;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: shouldLoad,
        initialData: false,
        builder: (context, snapshot) {
          return AnimatedCrossFade(
            duration: Duration(milliseconds: 350),
            crossFadeState: snapshot.data
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Color(0xfffffffa),
                  elevation: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Adding post, please wait...',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            secondChild: Container(),
          );
        });
  }
}
