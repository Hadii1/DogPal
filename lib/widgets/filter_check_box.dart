import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';

class FilterCheckBox extends StatefulWidget {
  const FilterCheckBox({
    @required this.onChanged,
    @required this.label,
    @required this.initialValue,
  });
  final String label;
  final Function(bool) onChanged;
  final bool initialValue;
  @override
  _FilterCheckBoxState createState() => _FilterCheckBoxState();
}

class _FilterCheckBoxState extends State<FilterCheckBox> {
  bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.label,
            style: normalTextStyle,
          ),
          RoundedCheckBox(
            value: _currentValue,
            onChanged: (selected) {
              _currentValue = selected;
              widget.onChanged(_currentValue);
              setState(() {});
              print(_currentValue);
            },
          ),
        ],
      ),
    );
  }
}

class RoundedCheckBox extends StatelessWidget {
  const RoundedCheckBox({@required this.onChanged, @required this.value});
  final Function(bool) onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: value ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: value ? 0 : 1,
              color: Colors.grey,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: value
                  ? Icon(
                      Icons.check,
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
