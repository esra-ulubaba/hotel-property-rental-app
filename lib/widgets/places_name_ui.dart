
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/global.dart';
import 'package:otel_ve_emlak_kiralama/models/adress_model.dart';
import 'package:otel_ve_emlak_kiralama/models/predicted_places.dart';




class PlacesNameUi extends StatefulWidget {
  final PredictedPlaces? predictedPlaceData;

  const PlacesNameUi({super.key, this.predictedPlaceData});

  @override
  State<PlacesNameUi> createState() => _PlacesNameUiState();
}

class _PlacesNameUiState extends State<PlacesNameUi> {


  retrieveClickedPlaceDetails(String placeID) async {
    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=${AppConstants.googleMapsKey}";

    var responseFromPlaceDetailsAPI = await CommonFunctions.sendRequestToAPI(urlPlaceDetailsAPI);

    if (responseFromPlaceDetailsAPI == "error") {
      return;
    }

    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      AddressModel propertyAddressDetails = AddressModel();

      propertyAddressDetails.fullAddress = responseFromPlaceDetailsAPI["result"]["formatted_address"];
      propertyAddressDetails.placeName = responseFromPlaceDetailsAPI["result"]["name"];
      propertyAddressDetails.latitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      propertyAddressDetails.longitudePosition = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"]; //geometrik konum ve enlem sonucu elde etmek için
      propertyAddressDetails.placeID = placeID; //adres id'nin kimliğine de atama işlemi yapılır.

      setState(() {
        addressOfProperty = propertyAddressDetails.fullAddress.toString();
        cityOfProperty = widget.predictedPlaceData!.main_text.toString();
        countryOfProperty = widget.predictedPlaceData!.secondary_text.toString();
      });

      Navigator.pop(context, "placeSelected"); //bu anahtarı parametre olarak ileteceğiz.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        retrieveClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString()); //Sınıf kimliği yardımıyla tıklandığında tüm içeriği getirir.
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaceData!.main_text.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.predictedPlaceData!.secondary_text.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
