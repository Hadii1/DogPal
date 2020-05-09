import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterChoiceChip extends StatefulWidget {
  const FilterChoiceChip({
    @required this.onChanged,
    @required this.title,
    @required this.values,
    @required this.initialValue,
  });

  final List<String> values;
  final String initialValue;
  final String title;
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
              padding: const EdgeInsets.only(bottom: 8.0),
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
                    if (selected) {
                      _selectedValue = e;
                      setState(() {});
                      widget.onChanged(_selectedValue);
                    }
                  },
                );
              }).toList(),
            )
          ],
        ));
  }
}
