enum DataState {
  loading,
  unknownError,
  networkError,
  postsAvailable,
  noDataAvailable,
  locationDenied,
  locationNetworkError,
  locationUnknownError,
  locationServiceOff
}

enum FavoriteType {
  adoption,
  mating,
}

enum PostAdditionState {
  loading,
  shouldNavigate,
  noInternet,
}

enum PostAdditionStatus {
  adding,
  successful,
  failed,
}

enum PostDeletionStatus {
  unInitiated,
  loading,
  successful,
  failed,
}


enum SignInMethod {
  fb,
  gmail,
}

enum ProfileScreenState {
  loading,
  unAuthenticated,
  authenticated,
}



enum LocationType {
  city,
  town,
  district,
}

enum WidgetOrientation {
  vertical,
  horizontal,
}

enum PostType {
  lost,
  adopt,
  mate,
}


enum UserDataState {
  loadingWithNoData,
  loadingWithData,
  postsReady,
  errorWithNoData,
  errorWithData,
}

enum DecisionState {
  unAuthenticated,
  askingPermission,
  fetchingLocation,
}