import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum DataState {
  loading,
  unknownError,
  networkError,
  fetchingNetworkError,
  postsAvailable,
  noDataAvailable,
  locationDenied,
  locationNetworkError,
  locationUnknownError,
}

enum PostAdditionState {
  loading,
  shouldNavigate,
  noInternet,
}

Future<bool> checkAndAskPermission({
  @required Permission permission,
}) async {
  PermissionStatus status = await permission.status;

  if (status == PermissionStatus.granted) {
    return true;
  } else if (status == PermissionStatus.permanentlyDenied) {
    return false;
  } else {
    PermissionStatus newStatus = await permission.request();

    if (newStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

Future<bool> isOnline() async {
  ConnectivityResult result = await Connectivity().checkConnectivity();
  if (result == ConnectivityResult.none) {
    return false; //Offline
  } else {
    return true; //Online
  }
}

String getMonth(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
  }

  return null;
}

String getTimeDifference(
  Timestamp timestamp, {
  Timestamp fakeCurrentTime,
}) {
  // currentTime parameter is for testing purposes

  Duration duration = (timestamp
          .toDate()
          .difference(fakeCurrentTime?.toDate() ?? DateTime.now()))
      .abs();
  if (duration.inDays <= 1) {
    if (duration.inDays == 1) {
      return 'Yesterday';
    }
    if (duration.inHours < 1) {
      return '${duration.inMinutes} mins ago';
    }
    return duration.inHours == 1
        ? 'One hour ago'
        : '${duration.inHours} hours ago';
  } else {
    if (duration.inDays >= 365) {
      int a = duration.inDays ~/ 365;
      return a == 1 ? 'One year ago' : '$a years ago';
    } else if (duration.inDays > 30) {
      int a = duration.inDays ~/ 30;
      return a == 1 ? 'One month ago' : '$a months ago';
    } else if (duration.inDays >= 7) {
      int a = duration.inDays ~/ 7;
      return a == 1 ? '1 week ago' : '$a weeks ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}
