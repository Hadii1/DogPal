import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/utils/mate_warnings.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';

class MateWarningScreen extends StatefulWidget {
  @override
  _MateWarningScreenState createState() => _MateWarningScreenState();
}

class _MateWarningScreenState extends State<MateWarningScreen> {
  bool _documentRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Warning')),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Things to consider before adding your dog for mating:',
                softWrap: true,
                style: TextStyle(
                  color: blackishColor,
                  fontSize: 21,
                  fontFamily: 'OpenSans',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                child: Text(MATE_WARNING),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'I have read and understood the document',
                      style: TextStyle(fontFamily: 'OpenSans'),
                    ),
                  ),
                  Checkbox(
                    value: _documentRead,
                    onChanged: (value) {
                      setState(() {
                        _documentRead = value;
                      });
                    },
                  )
                ],
              ),
              FlatButton(
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _documentRead
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  width: double.maxFinite,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(14.0),
                    alignment: Alignment.center,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () => _documentRead
                    ? Navigator.of(context).pushNamed(MateRoutes.ADD_MATE_DOG)
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
