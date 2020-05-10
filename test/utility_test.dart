import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/utils/dog_util.dart';
import 'package:flutter_test/flutter_test.dart';
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
