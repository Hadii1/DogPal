import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';

class GenderFilter extends StatefulWidget {
  const GenderFilter({
    @required this.onChanged,
    this.initialValue,
  });

  final Function(String) onChanged;
  final String initialValue;

  @override
  _GenderFilterState createState() => _GenderFilterState();
}

class _GenderFilterState extends State<GenderFilter> {
  String _groupValue;

  @override
  void initState() {
    _groupValue = widget.initialValue ?? 'Female';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Gender',
          style: subHeaderStyle,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                CustomRadio(
                  value: 'Male',
                  groupValue: _groupValue,
                  onChanged: (value) {
                    setState(() {
                      if (_groupValue == value) {
                        _groupValue = '';
                      } else {
                        _groupValue = value;
                      }

                      widget.onChanged(_groupValue);
                    });
                  },
                ),
                Text(
                  'Male',
                  style: normalTextStyle,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                CustomRadio(
                  value: 'Female',
                  groupValue: _groupValue,
                  onChanged: (value) {
                    setState(() {
                      if (_groupValue == value) {
                        _groupValue = '';
                      } else {
                        _groupValue = value;
                      }

                      widget.onChanged(_groupValue);
                    });
                  },
                ),
                Text(
                  'Female',
                  style: normalTextStyle,
                ),
              ],
            )
          ],
        )
      ]),
    );
  }
}

class CustomRadio extends StatelessWidget {
  const CustomRadio({
    @required this.onChanged,
    @required this.groupValue,
    @required this.value,
  });
  final Function(String) onChanged;
  final String groupValue;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        onChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          width: 19,
          height: 19,
          decoration: BoxDecoration(
            color: groupValue == value
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: groupValue == value ? 0 : 1,
              color: Colors.grey,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: groupValue == value
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
