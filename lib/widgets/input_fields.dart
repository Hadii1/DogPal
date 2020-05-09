import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField({this.onChanged});
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: TextField(
        autocorrect: true,
        autofocus: false,
        maxLength: 800,
        onChanged: (value) => onChanged(value),
        keyboardType: TextInputType.text,
        maxLines: 4,
        style: TextStyle(fontFamily: 'OpenSans'),
        decoration: InputDecoration(
          labelText: 'Description',
          helperMaxLines: 2,
          helperText: 'Any information you\'d like to add',
          labelStyle: TextStyle(
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({
    @required this.nameKey,
    @required this.onChanged,
  });

  final GlobalKey<FormState> nameKey;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: Form(
        key: nameKey,
        child: TextFormField(
          autocorrect: false,
          autofocus: false,
          validator: (input) {
            if (input.isEmpty) return ("kindly add the dog's name");
            return null;
          },
          onChanged: (name) => onChanged(name),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          maxLength: 12,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 0.4, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            counter: SizedBox.shrink(),
            fillColor: Colors.grey[200],
            labelText: 'Dog name',
            labelStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: ScreenUtil().setSp(40),
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({
    this.onChanged,
  });
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: TextField(
        autocorrect: false,
        autofocus: false,
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.phone,
        onChanged: (number) => onChanged(number),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          helperMaxLines: 5,
          helperText:
              'If not filled, your email address will be the primary way of contact.',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              width: 0.1,
              color: Theme.of(context).primaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 0.3,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                width: 0.7,
                color: Theme.of(context).primaryColor,
              )),
          labelText: 'Phone Number',
          labelStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: ScreenUtil().setSp(40),
          ),
        ),
      ),
    );
  }
}

class AgePicker extends StatefulWidget {
  const AgePicker({this.onChaged});
  final Function(String) onChaged;
  @override
  _AgePickerState createState() => _AgePickerState();
}

class _AgePickerState extends State<AgePicker> {
  int _years = 0;
  int _months = 0;
  String _age;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Years'),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: NumberPicker.integer(
                  initialValue: _years,
                  minValue: 0,
                  maxValue: 30,
                  onChanged: (value) {
                    setState(() {});
                    _years = value;
                    _age = getAgeText();
                    widget.onChaged(_age);
                  }),
            )
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Months'),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: NumberPicker.integer(
                  initialValue: _months,
                  minValue: 0,
                  maxValue: 11,
                  onChanged: (value) {
                    setState(() {});
                    _months = value;
                    _age = getAgeText();
                    widget.onChaged(_age);
                  }),
            )
          ],
        )
      ],
    );
  }

  String getAgeText() {
    if (_years == 0 && _months != 0) {
      return _months == 1 ? '$_months month' : '$_months months';
    } else if (_years != 0 && _months == 0) {
      return _years == 1 ? '$_years year' : '$_years years';
    } else if (_years != 0 && _months != 0) {
      return _years == 1 ? '$_years.$_months year' : '$_years.$_months years';
    } else {
      //both zero
      return 'Age : ';
    }
  }
}

class AgeField extends StatefulWidget {
  const AgeField({
    this.initialAge,
    this.onChanged,
  });

  final String initialAge;
  final Function(String) onChanged;

  @override
  _AgeFieldState createState() => _AgeFieldState();
}

class _AgeFieldState extends State<AgeField> {
  String _age;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: ActionChip(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        label: Text( _age ?? 'Age : '),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  content: AgePicker(
                    onChaged: (value) {
                      setState(() {
                        _age = value;
                      });
                      widget.onChanged(value);
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}
