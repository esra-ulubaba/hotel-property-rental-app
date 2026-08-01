class AddressModel {
  String? humanReadableAddress;
  String? fullAddress;
  double? latitudePosition; //enlem konumu
  double? longitudePosition; //boylam konumu
  String? placeID;
  String? placeName;

  AddressModel({
    this.humanReadableAddress,
    this.fullAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
  });
}