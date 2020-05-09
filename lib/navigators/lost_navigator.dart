import 'package:dog_pal/bloc/add_lost_dog_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/screens/lost/add_lost_dog.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LostNavigator extends StatelessWidget {
  LostNavigator(this.navigatorKey);
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
            settings: setting,
            builder: (BuildContext context) {
              switch (setting.name) {
                case LostRoutes.ADD_LOST_DOG:
                  return Provider(
                    create: (_) => AddLostDogBloc(
                        Provider.of<AppBloc>(context, listen: false),
                        Provider.of<LocalStorage>(context, listen: false)),
                    child: AddLostDogScreen(),
                  );
                  break;

                case LostRoutes.LOST_DOG_DETAILS_SCREEN:
                  assert(setting.arguments is LostDetailsArgs);
                  return LostDogDetailsScreen(setting.arguments);
                  break;

                default:
                  return DogsScreen(
                    postType: PostType.lost,
                  );

                  break;
              }
            });
      },
    );
  }
}

class LostRoutes {
  static const String LOST_SCREEN = '/lostScreen';
  static const String LOST_DOG_DETAILS_SCREEN = '/detailsScreen';
  static const String ADD_LOST_DOG = '/addLostDog';
}
