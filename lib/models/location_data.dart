class LocationData {
  final String town;
  final String city;
  final String district;
  final String display;

  LocationData({
    this.city,
    this.district,
    this.town,
    this.display,
  });

  static Map<String, String> toJson(LocationData data) {
    return {
      'town': data.town,
      'city': data.city,
      'district': data.district,
      'display': data.display
    };
  }

  factory LocationData.fromJson(Map<String, String> map) {
    return LocationData(
      city: map['city'],
      town: map['town'],
      district: map['district'],
      display: map['display'],
    );
  }
}
