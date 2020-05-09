import 'package:dog_pal/navigators/adopt_navigator.dart';
import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/screens/profile/favorites_screen.dart';
import 'package:dog_pal/screens/profile/posts_Screen.dart';
import 'package:dog_pal/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'lost_navigator.dart';

class ProfileRoutes {
  static const String PROFILE_SCREEN = '/profileScreen';
  static const String POSTS_SCREEN = '/postsScreen';
  static const String FAVORTIES_SCREEN = '/favoritesScreen';
  static const String TERMS_SCREEN = '/termsScreen';
  static const String PRIVACY_POLICY_SCREEN = '/privacyPolicy';
  static const String CREDENTIALS_SCREEN = '/credetials';
}

class ProfileNavigator extends StatelessWidget {
  ProfileNavigator(this.navigatorKey);
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
          settings: setting,
          builder: (context) {
            switch (setting.name) {
              case LostRoutes.LOST_DOG_DETAILS_SCREEN:
                assert(setting.arguments is LostDetailsArgs);
                return LostDogDetailsScreen(setting.arguments);
                break;

              case ProfileRoutes.TERMS_SCREEN:
                return TermsScreen();
                break;

              case ProfileRoutes.PRIVACY_POLICY_SCREEN:
                return PrivacyPolicyScreen();
                break;

              case ProfileRoutes.CREDENTIALS_SCREEN:
                return CredentialsScreen();
                break;

              case MateRoutes.MATE_DOG_WALL:
                assert(setting.arguments is MateDetailsArgs);
                return MateDogDetailsScreen(setting.arguments);
                break;

              case ProfileRoutes.POSTS_SCREEN:
                return PostsScreen();
                break;

              case AdoptRoutes.ADOPTION_DOG_WALL:
                assert(setting.arguments is AdoptDetailsArgs);
                return AdoptionDogWall(setting.arguments);
                break;

              case ProfileRoutes.FAVORTIES_SCREEN:
                return FavoritesScreen();
                break;

              default:
                return ProfileScreen();
                break;
            }
          },
        );
      },
    );
  }
}
