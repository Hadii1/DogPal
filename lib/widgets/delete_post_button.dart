import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DeletePostButton extends StatelessWidget {
  const DeletePostButton({
    @required this.fullWidth,
    @required this.onDeletePressed,
    @required this.onRetryPressed,
    @required this.statusStream,
    this.onCancelPressed,
  });

  final Function() onDeletePressed;
  final Function() onCancelPressed;
  final Function() onRetryPressed;

  final Stream<PostDeletionStatus> statusStream;
  final double fullWidth;

  double _getActiveWidth(PostDeletionStatus status, BuildContext context) {
    switch (status) {
      case PostDeletionStatus.unInitiated:
        return fullWidth / 2;
        break;
      case PostDeletionStatus.loading:
        return fullWidth;
        break;
      case PostDeletionStatus.successful:
        return fullWidth / 1.5;
        break;
      case PostDeletionStatus.failed:
        return fullWidth;
        break;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PostDeletionStatus>(
      initialData: PostDeletionStatus.unInitiated,
      stream: statusStream,
      builder: (_, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              width: _getActiveWidth(snapshot.data, context),
              height: 50,
              child: (() {
                switch (snapshot.data) {
                  case PostDeletionStatus.unInitiated:
                    return UninitiatedButton(
                      onSumbitPressed: onDeletePressed,
                    );
                    break;
                  case PostDeletionStatus.successful:
                    return SuccessfulButton();
                    break;
                  case PostDeletionStatus.failed:
                    return LoadingOrFailedButton(
                      onCancelPressed: onCancelPressed,
                      onRetryPressed: onRetryPressed,
                      status: PostDeletionStatus.failed,
                    );
                    break;
                  case PostDeletionStatus.loading:
                    return LoadingOrFailedButton(
                      onCancelPressed: onCancelPressed,
                      onRetryPressed: onRetryPressed,
                      status: PostDeletionStatus.loading,
                    );
                    break;
                  default:
                    return null;
                }
              }()),
            ),
          ),
        );
      },
    );
  }
}

class UninitiatedButton extends StatelessWidget {
  const UninitiatedButton({@required this.onSumbitPressed});
  final Function() onSumbitPressed;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onSumbitPressed,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none,
      ),
      color: blackishColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingOrFailedButton extends StatelessWidget {
  const LoadingOrFailedButton({
    @required this.onCancelPressed,
    @required this.onRetryPressed,
    @required this.status,
  });
  final Function() onCancelPressed;
  final Function() onRetryPressed;
  final PostDeletionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        color: yellowishColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 50,
            height: double.maxFinite,
            child: Material(
              color: blackishColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200),
              ),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == PostDeletionStatus.failed
                      ? Colors.red
                      : blackishColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (status == PostDeletionStatus.failed) {
                        return onCancelPressed != null
                            ? InkWell(
                                onTap: onCancelPressed,
                                child: Icon(Icons.close, color: Colors.white),
                              )
                            : SizedBox.shrink();
                      } else {
                        return SpinKitThreeBounce(
                          color: Colors.white,
                          size: constraints.maxWidth / 2,
                          duration: Duration(milliseconds: 1200),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: status == PostDeletionStatus.failed
                    ? Text(
                        'Oops.. Something went wrong!',
                        textAlign: TextAlign.center,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 250),
            crossFadeState: status == PostDeletionStatus.failed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: SizedBox(
              height: double.maxFinite,
              width: 50,
              child: IconButton(
                icon: Icon(Icons.replay),
                onPressed: onRetryPressed,
                color: Colors.black54,
              ),
            ),
            secondChild: SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}

class SuccessfulButton extends StatefulWidget {
  const SuccessfulButton();

  @override
  _SuccessfulButtonState createState() => _SuccessfulButtonState();
}

class _SuccessfulButtonState extends State<SuccessfulButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      upperBound: 25,
      lowerBound: 0,
      duration: Duration(milliseconds: 250),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).primaryColor,
        ),
        borderRadius: BorderRadius.circular(200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Success',
              style: TextStyle(
                color: blackishColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: _animationController.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
