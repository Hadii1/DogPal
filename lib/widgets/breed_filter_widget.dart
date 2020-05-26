import 'package:dog_pal/utils/dog_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum WidgetOrientation {
  vertical,
  horizontal,
}

class BreedFilterWidget extends StatefulWidget {
  const BreedFilterWidget({
    @required this.onChanged,
    @required this.orientation,
    this.initalBreed,
  });

  final WidgetOrientation orientation;
  final Function(String) onChanged;
  final String initalBreed;

  @override
  _BreedFilterWidgetState createState() => _BreedFilterWidgetState();
}

class _BreedFilterWidgetState extends State<BreedFilterWidget> {
  String _currentBreed;

  @override
  void initState() {
    _currentBreed = widget.initalBreed != null && widget.initalBreed.isNotEmpty
        ? widget.initalBreed
        : 'Any';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: widget.orientation == WidgetOrientation.vertical
          ? _buildVerticalWidget()
          : _buildHorizontalWidget(),
    );
  }

  Widget _buildVerticalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Breed', style: subHeaderStyle),
        ActionChip(
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          label: Text(
            _currentBreed,
            softWrap: true,
            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
          ),
          onPressed: () => _showBreedDialog(context),
        )
      ],
    );
  }

  Widget _buildHorizontalWidget() {
    return InkWell(
      onTap: () => _showBreedDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Breed:  ',
            style: subHeaderStyle,
          ),
          ActionChip(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            label: Text(
              _currentBreed,
              softWrap: true,
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
            onPressed: () => _showBreedDialog(context),
          )
        ],
      ),
    );
  }

  _showBreedDialog(BuildContext context) async {
    _currentBreed = await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) {
              return BreedsDialog();
            },
          ),
        ) ??
        _currentBreed ??
        'Any';
    widget.onChanged(_currentBreed);
  }
}

class BreedsDialog extends StatefulWidget {
  @override
  _BreedsDialogState createState() => _BreedsDialogState();
}

class _BreedsDialogState extends State<BreedsDialog> {
  List dogSuggestions = DogUtil.DOG_BREEDS;

  final _controller = TextEditingController();

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        dogSuggestions = DogUtil.getSuggestions(_controller.text);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Specify Breed', style: TextStyle(fontSize: 60.sp)),
        leading: IconButton(
          icon: Icon(
            Icons.close,
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: blackishColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            _buildSearchBar(),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: dogSuggestions.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, dogSuggestions[index]);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: blackishColor,
                              ),
                              child: Text(''),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                dogSuggestions[index],
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w300,
                                  color: blackishColor,
                                  fontSize: ScreenUtil().setSp(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 2),
      child: SizedBox(
        height: 200.h,
        child: Card(
          elevation: 1,
          color: Color(0xfffffffa),
          child: Center(
            child: TextField(
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: blackishColor,
                fontSize: 55.sp,
              ),
              controller: _controller,
              autofocus: true,
              decoration: (InputDecoration(
                labelText: 'Search Breeds',
                labelStyle: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 55.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 85.sp,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
