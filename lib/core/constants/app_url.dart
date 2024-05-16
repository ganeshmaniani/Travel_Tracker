class ApiUrl {
  static var baseGoogleApi = 'https://maps.googleapis.com/maps/';
/// Google Map Api EndPoints
  /// Autocomplete Place API EndPoints
  static var autoCompletePlaceEntPoint =
      '${baseGoogleApi}api/place/autocomplete/json';

  /// Place Id To Get Latitude Longitude Api EndPoints
  static var placeIdToLatLangEntPoint =
      '${baseGoogleApi}api/geocode/json'; // place_id=gsdg3er&key=qdgf34

  /// Latitude Longitude To Get Place Api EndPoints
  static var latLangToPlaceEntPoint =
      '${baseGoogleApi}api/geocode/json'; // latlang=12.43,12.45&key=zxbveq43dvd

  /// Direction Api EndPoints
  static var directionEntPoint =
      '${baseGoogleApi}api/place/nearbysearch/json'; // origin=12.43,12.45&destination=23.43,54.21&key=zxbveq43dvd

}
