class FirestoreConsts {
  static const int DOCS_LIMIT = 40;
  static const String USER_COLLECTION = 'Users';
  static const String LOST_DOGS = 'LostDogs';
  static const String MATE_DOGS = 'MatingDogs';
  static const String ADOPTION_DOGS = 'AdoptionDogs';
}

class PostsConsts {
  static const String DATE_ADDED = 'Date added';
  static const String DESCRIPTION = 'Description';
  static const String DISTRICT = 'District';
  static const String CITY = 'City';
  static const String TOWN = 'Town';
  static const String LOCATION_DISPLAY = 'location display';
  static const String POST_ID = 'Post id';
  static const String POST_TYPE = 'Type';
}

class DogConsts {
  static const String DOG_BREED = 'Dog breed';
  static const String DOG_NAME = 'Dog name';
  static const String PEDIGREE = 'Pedigree';
  static const String GENDER = 'Gender';
  static const String IMAGES = 'Images';
  static const String COAT_COLORS = 'Coat colors';
  static const String BARK_TENDENCY = 'Bark tendency';
  static const String SHEDDING_LEVEL = 'Shedding level';
  static const String TRAINING_LEVEL = 'Training level';
  static const String ENERGY_LEVEL = 'Energy level';
  static const String Size = 'Size';
  static const String PET_FRIENDLY = 'Pet friendly';
  static const String APPARTMENT_FRIENDLY = 'Appartment friendly';
  static const String VACCINATED = 'Vaccienated';
  static const String AGE = 'age';
}

class UserConsts {
  static const String USERNAME = 'Name';
  static const String FIRST_NAME = 'first_name';
  static const String DATE_JOINED = 'Date';
  static const String USER_EMAIL = 'Email';
  static const String USER_PHOTO = 'Photo';
  static const String USER_UID = 'Uid';
  static const String PHONE_NUMBER = 'phone number';
  static const String FAVORITE = 'favorite posts';
  static const String LOCATION_DISPLAY = 'location display';
  static const String TOWN = 'User town';
  static const String CITY = 'User city';
  static const String DISTRICT = 'User district';
}

class GeneralConstants {
  static const String NO_INTERNET_CONNECTION = 'No Internet Connection';
  static const String LOCATION_PERMISSION_ERROR =
      'Kindly enable location access for more efficient use of the app';

  static const String IMAGE_PERMISSION_ERROR = 'Please enable storage access.';

  static const Map<dynamic, dynamic> defaultLocation = {
    UserConsts.TOWN: 'Scottsdale',
    UserConsts.CITY: 'Maricopa County',
    UserConsts.DISTRICT: 'Arizona',
    UserConsts.LOCATION_DISPLAY: 'Scottsdale',
  };
}

class AuthErrors {
  static const String INVALID = 'ERROR_INVALID_EMAIL';
  static const String WRONG_PASSWORD = 'ERROR_WRONG_PASSWORD';
  static const String USER_NOT_FOUND = 'ERROR_USER_NOT_FOUND';
  static const String MANY_ATTEMPTS = 'ERROR_TOO_MANY_REQUESTS';
  static const String WEAK_PASSWORD = 'ERROR_WEAK_PASSWORD';
  static const String EMAIL_IN_USE = 'ERROR_EMAIL_ALREADY_IN_USE';
  static const String ACCOUNT_EXISTS =
      'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL';
  static const String NETWORK_ERROR = 'ERROR_NETWORK_REQUEST_FAILED';
}

// ERROR_INVALID_CREDENTIAL - If the credential data is malformed or has expired.
// ERROR_USER_DISABLED - If the user has been disabled (for example, in the Firebase console)
// ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL - If there already exists an account with the email
// address asserted by Google.
//Resolve this case by calling [fetchSignInMethodsForEmail] and then asking the user
// to sign in using one of them.
//This error will only be thrown if the "One account per email address" setting is enabled in the Firebase console
//(recommended).
// ERROR_OPERATION_NOT_ALLOWED - Indicates that Google accounts are not enabled.
// ERROR_INVALID_ACTION_CODE - If the action code in the link is malformed, expired,
//or has already been used. This can only occur when using [EmailAuthProvider.getCredentialWithLink]
// to obtain the credential
