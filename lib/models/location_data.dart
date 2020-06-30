class UserLocationData {
  final String userTown;
  final String userCity;
  final String userDistrict;
  final String userDisplay;

  UserLocationData({
    this.userCity,
    this.userDistrict,
    this.userTown,
    this.userDisplay,
  });

  static Map<String, String> toJson(UserLocationData data) {
    return {
      'userTown': data.userTown,
      'userCity': data.userCity,
      'userDistrict': data.userDistrict,
      'userLocationDisplay': data.userDisplay
    };
  }

  factory UserLocationData.fromJson(Map<String, String> map) {
    return UserLocationData(
      userCity: map['userCity'],
      userTown: map['userTown'],
      userDistrict: map['userDistrict'],
      userDisplay: map['userLocationDisplay'],
    );
  }
}

class PostLocationData {
  String postTown;
  String postDistrict;
  String postCity;
  String postDisplay;

  PostLocationData({
    this.postCity,
    this.postDistrict,
    this.postTown,
    this.postDisplay,
  });

  static Map<String, String> toJson(PostLocationData data) {
    return {
      'postTown': data.postTown,
      'postCity': data.postCity,
      'postDistrict': data.postDistrict,
      'postLocationDisplay': data.postDisplay,
    };
  }

  factory PostLocationData.fromJson(Map<String, String> map) {
    return PostLocationData(
      postCity: map['postCity'],
      postDistrict: map['postDistrict'],
      postTown: map['postTown'],
      postDisplay: map['postLocationDisplay'],
    );
  }
}
