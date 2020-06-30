import 'package:dog_pal/utils/dog_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoatColor extends StatefulWidget {
  const CoatColor({
    @required this.onChanged,
    this.initialColors,
  });

  final Function(List<String>) onChanged;
  final List<String> initialColors;

  @override
  _CoatColorState createState() => _CoatColorState();
}

class _CoatColorState extends State<CoatColor> {
  List<String> _selectedColors;

  @override
  void initState() {
    _selectedColors = widget.initialColors ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Coat Color(s)',
            style: subHeaderStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DogUtil.DOG_COLORS.map((color) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilterChip(
                      labelPadding: EdgeInsets.symmetric(horizontal: 2),
                      backgroundColor: Colors.grey[200],
                      checkmarkColor: Colors.white,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          color,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            color: _selectedColors.contains(color)
                                ? Colors.white
                                : Colors.black87,
                            fontSize: ScreenUtil().setSp(40),
                          ),
                        ),
                      ),
                      selected: _selectedColors.contains(color),
                      onSelected: (selected) {
                        if (selected) {
                          _selectedColors.add(color);
                        } else {
                          _selectedColors.removeWhere((name) {
                            return color == name;
                          });
                        }

                        widget.onChanged(_selectedColors);
                        setState(() {});
                      },
                      selectedColor: Theme.of(context).primaryColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
