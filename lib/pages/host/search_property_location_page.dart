import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/predicted_places.dart';
import 'package:otel_ve_emlak_kiralama/widgets/places_name_ui.dart';


class SearchPropertyLocationPage extends StatefulWidget {
  const SearchPropertyLocationPage({super.key});

  @override
  State<SearchPropertyLocationPage> createState() => _SearchPropertyLocationPageState();
}

class _SearchPropertyLocationPageState extends State<SearchPropertyLocationPage> {

  TextEditingController placeAddressTextEditingController = TextEditingController();
  List<PredictedPlaces> placesList = [];




  searchLocation(String locationName) async {
    if (locationName.length > 1) { //sunucunun metin alanına girdiği ve bizim de gireceğimiz metin
      String apiPlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=${AppConstants.googleMapsKey}&components=country:tr"; //api adresleriminin api url'si

      var responseFromPlacesAPI =
      await CommonFunctions.sendRequestToAPI(apiPlacesUrl); //API'ye istek gönderiyoruz.

      if (responseFromPlacesAPI == "error") { //hata durumu olup olmadığını kontrol ediyoruz.
        return;
      }

      if (responseFromPlacesAPI["status"] == "OK") { //hata yoksa API durumundan gelen yanıt bu şekilde olur. Google Maps Platformda da böyle.
        var predictionResultInJson = responseFromPlacesAPI["predictions"]; //tahmin edilen değişkenleri alıyoruz.
        var predictionsList = (predictionResultInJson as List) //Json formatında sunuyoruz.
            .map((eachPlacePrediction) =>
            PredictedPlaces.fromJson(eachPlacePrediction))
            .toList();

        setState(() { //bunu kullanarak tahmin listesini yerler listesine atıyoruz.
          placesList = predictionsList; //elimizde olan datalarla tahmin edilen konum verilerini kullanıcı arayüzünde kolayca görüntüleyebiliriz.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Colors.black,
              elevation: 5,
              child: Container(
                height: 164,
                padding: const EdgeInsets.only(
                    left: 24, top: 48, right: 24, bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // icon button - title
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Lütfen adresi yazın.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // input text field
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/final.png",
                          height: 16,
                          width: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: TextField(
                                controller: placeAddressTextEditingController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                onChanged: (inputText) {
                                  searchLocation(inputText);
                                },
                                decoration: const InputDecoration(
                                  hintText: "buraya yazın...",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.black,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 9, bottom: 9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // display prediction results for property places
            (placesList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[850],
                    elevation: 3,
                    child: PlacesNameUi(
                      predictedPlaceData: placesList[index],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                const SizedBox(height: 2),
                itemCount: placesList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
