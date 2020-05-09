import 'package:connectivity/connectivity.dart';
import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/screens/home.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

void main() {
  MockLocalStorage storageMock;

  setUpAll(() {
    storageMock = MockLocalStorage();

    when(storageMock.getLocationData()).thenReturn({
      UserConsts.CITY: '_testing',
      UserConsts.TOWN: '_testing',
      UserConsts.DISTRICT: '_testing',
    });

    when(storageMock.isAuthenticated()).thenReturn(false);

    when(storageMock.getPostLocationData()).thenReturn({
      UserConsts.CITY: '_testing',
      UserConsts.TOWN: '_testing',
      UserConsts.DISTRICT: '_testing',
    });

    //Return the connectivity checking result manually
    const MethodChannel(
      'plugins.flutter.io/connectivity',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return ConnectivityResult.wifi;
      }
      return null;
    });
  });
  testWidgets(
    'Lists are initially loading',
    (WidgetTester tester) async {
      await tester.pumpWidget(DogsScreenTestWidget(storageMock));

      // await tester.pump(
      //   Duration(milliseconds: 500),
      // ); //we need to await the fader widget which runs a 300ms animation

      // expect(find.byType(LoadingWidget), findsNWidgets(3));
      expect(find.byType(NoDogsWidget), findsNWidgets(0));
    },
  );

  testWidgets('Empty state of lists', (WidgetTester tester) async {
    await tester.runAsync(() async {
      try {
        await tester.pumpWidget(DogsScreenTestWidget(storageMock));

        await Future.delayed(Duration(seconds: 4));
        await tester.pump();
        expect(find.byType(NoDogsWidget), findsNWidgets(3));
      } on MissingPluginException catch (_) {
        print('throwing');
      }
    });
  });
}

class MockLocalStorage extends Mock implements LocalStorage {}

class DogsScreenTestWidget extends StatelessWidget {
  DogsScreenTestWidget(this.storageMock);
  final LocalStorage storageMock;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<AppBloc>(
            create: (_) => AppBloc(),
          ),
          Provider<LocalStorage>(
            create: (_) => storageMock,
          ),
          Provider<LostBloc>(
            create: (_) => LostBloc(
              storageMock,
            ),
          ),
          Provider<AdoptBloc>(
            create: (_) => AdoptBloc(storageMock),
          ),
          Provider<MateBloc>(
            create: (_) => MateBloc(storageMock),
          ),
        ],
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen();
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1242, height: 2688, allowFontScaling: true);
    return Home();
  }
}
