import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterChoiceChip extends StatefulWidget {
  const FilterChoiceChip({
    @required this.onChanged,
    @required this.title,
    @required this.values,
    @required this.initialValue,
    @required this.isRequired,
  });

  final List<String> values;
  final String initialValue;
  final String title;
  final bool isRequired;
  final Function(String) onChanged;

  @override
  _FilterChoiceChipState createState() => _FilterChoiceChipState();
}

class _FilterChoiceChipState extends State<FilterChoiceChip> {
  String _selectedValue;

  @override
  void initState() {
    _selectedValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
              child: Text(
                widget.title,
                style: subHeaderStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.values.map((e) {
                return ChoiceChip(
                  backgroundColor: Colors.grey[200],
                  label: Text(
                    e,
                    style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                  ),
                  selected: _selectedValue == e,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedValue = e;
                      } else {
                        if (!widget.isRequired) {
                          _selectedValue = '';
                        }
                      }
                      widget.onChanged(_selectedValue);
                    });
                  },
                );
              }).toList(),
            )
          ],
        ));
  }
}
