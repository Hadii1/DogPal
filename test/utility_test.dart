import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/dog_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dog_pal/utils/extensions_util.dart';
import 'package:dog_pal/utils/general_functions.dart';

void main() {

  group('Dog breeds suggestions', () {
    test('Suggestions number', () {
      List<String> suggestions = DogUtil.getSuggestions('Affenpinscher');

      expect(suggestions.length, 1);
    });

    test('Lower case', () {
      List<String> suggestions = DogUtil.getSuggestions('affenpinsch');

      expect(suggestions.length, 1);
    });

    test('Suggestions content', () {
      List<String> suggestions = DogUtil.getSuggestions('Affenpinscher');
      expect(suggestions[0], 'Affenpinscher');
    });

    test('Multiple suggestions', () {
      List<String> suggestions = DogUtil.getSuggestions('American');
      expect(suggestions.length, 10);
    });
  });

  test('Degree to Radian', () {
    double a = 37.2342314;
    double aRadian = a.toRadian();
    expect(aRadian, 0.649859932);
    //0.6498599323778

    //-0.211783923757
    double g = -12.134325;
    double gRadian = g.toRadian();
    expect(gRadian, -0.211783924);
  });

  test('Distance from lat and lng', () {
    double lat1 = 33.8547;
    double lng1 = 35.8623;
    double lat2 = 38.9637;
    double lng2 = 35.2433;

    int distance = getDistance(
      lat1: lat1,
      lat2: lat2,
      lng1: lng1,
      lng2: lng2,
    );

    expect(distance, 571);

    double llat1 = 50.0359;
    double llng1 = -5.4253;
    double llat2 = 58.3838;
    double llng2 = -3.0412;

    int ddistance = getDistance(
      lat1: llat1,
      lat2: llat2,
      lng1: llng1,
      lng2: llng2,
    );

    expect(ddistance, 941);

    double lllat1 = 30.031259;
    double lllng1 = -22.421253;
    double lllat2 = 43.233838;
    double lllng2 = 12.321412;

    int dddistance = getDistance(
      lat1: lllat1,
      lat2: lllat2,
      lng1: lllng1,
      lng2: lllng2,
    );

    expect(dddistance, 3398);

    double llllat1 = 30.031259;
    double llllng1 = -22.421253;
    double llllat2 = 30.031259;
    double llllng2 = -22.421253;

    int ddddistance = getDistance(
      lat1: llllat1,
      lat2: llllat2,
      lng1: llllng1,
      lng2: llllng2,
    );

    expect(ddddistance, 0);
  });

  group('Time difference', () {
    Timestamp fakeCurrentTime =
        Timestamp.fromDate(DateTime(2020, 1, 1, 4, 0, 0));
    // 1/1/2020 at 4:00 am

    test('Same timing', () {
      expect(
          getTimeDifference(
            fakeCurrentTime,
            fakeCurrentTime: fakeCurrentTime,
          ),
          '0 mins ago');
    });

    test('Minutes ago', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 1, 4, 5));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          '5 mins ago');
    });

    test('hours ago', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 1, 7, 20));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          '3 hours ago');
    });

    test('3 days ago', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 4, 7, 20));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          '3 days ago');
    });

    test('yesterday', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 2, 5, 20));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          'Yesterday');
    });

    test('1 week ago', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 8, 4, 1));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          '1 week ago');
    });

    test('2 weeks ago', () {
      Timestamp timestamp = Timestamp.fromDate(DateTime(2020, 1, 15, 4, 1));
      expect(getTimeDifference(timestamp, fakeCurrentTime: fakeCurrentTime),
          '2 weeks ago');
    });
  });
}
