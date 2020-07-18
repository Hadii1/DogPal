import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SizeFilter extends StatefulWidget {
  const SizeFilter({
    @required this.onChanged,
    this.initialValue,
    @required this.isRequired,
  });
  final Function(String) onChanged;
  final String initialValue;
  final bool isRequired;

  @override
  _SizeFilterState createState() => _SizeFilterState();
}

class _SizeFilterState extends State<SizeFilter> {
  final List<String> _sizes = ['Toy', 'Small', 'Medium', 'Large', 'Extra'];
  String _selectedSize;
  String _sizeUnit = 'lb';

  @override
  void initState() {
    _selectedSize = widget.initialValue ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  'Size',
                  style: subHeaderStyle,
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  if (_sizeUnit == 'lb') {
                    _sizeUnit = 'kg';
                  } else {
                    _sizeUnit = 'lb';
                  }
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: AnimatedCrossFade(
                    duration: Duration(milliseconds: 200),
                    crossFadeState: _sizeUnit == 'kg'
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      child: Text(
                        'Kilograms',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: ScreenUtil().setSp(42),
                        ),
                      ),
                    ),
                    secondChild: Text(
                      'Pounds',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: ScreenUtil().setSp(42),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sizes.map(
                  (size) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ChoiceChip(
                            backgroundColor: Colors.grey[200],
                            labelPadding: EdgeInsets.symmetric(horizontal: 2),
                            label: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Text(
                                  size,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(42),
                                  ),
                                ),
                              ),
                            ),
                            selected: _selectedSize == size,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSize = size;
                                } else {
                                  if (!widget.isRequired) {
                                    _selectedSize = '';
                                  }
                                }
                                widget.onChanged(_selectedSize);
                              });
                            },
                          ),
                        ),
                        AnimatedSwitcher(
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              child: child,
                              scale: animation,
                            );
                          },
                          duration: Duration(milliseconds: 200),
                          child: _sizeUnit == 'kg'
                              ? Container(
                                  child: Text(
                                    _kgSize(size),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                    ),
                                  ),
                                )
                              : Text(
                                  _lbSize(size),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                  ),
                                ),
                        )
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _lbSize(String size) {
    switch (size) {
      case 'Toy':
        return '0-12';
        break;
      case 'Small':
        return '12-25';
        break;
      case 'Medium':
        return '25-50';
        break;

      case 'Large':
        return '50-100';
        break;
      case 'Extra':
        return '100+';
        break;
    }
    return null;
  }

  String _kgSize(String size) {
    switch (size) {
      case 'Toy':
        return '0-5';
        break;
      case 'Small':
        return '5-11';
        break;
      case 'Medium':
        return '11-22';
        break;

      case 'Large':
        return '22-45';
        break;
      case 'Extra':
        return '45+';
        break;
    }
    return null;
  }
}
