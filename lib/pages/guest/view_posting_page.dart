import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/models/review_objects.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/book_posting_page.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/review_form_ui.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/view_profile_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/posting_info_tile.dart';
import 'package:otel_ve_emlak_kiralama/widgets/review_design_tile_ui.dart';

import '../../constants/app_constants.dart';
import '../../models/posting_objects.dart';


class ViewPostingPage extends StatefulWidget {
  static final String routeName = '/viewPostingRoute';

  final Posting? posting;

  const ViewPostingPage({super.key, this.posting,});

  @override
  State<ViewPostingPage> createState() => _ViewPostingPageState();
}



class _ViewPostingPageState extends State<ViewPostingPage> {
  Posting? _posting;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng _propertyLatLong = LatLng(37.42796133580664, -122.085749655962);

  BitmapDescriptor? customIcon;

  bool _canSubmitReview = false;

  _checkIfUserCanReview() async {
    try {
      // Firestore'dan bu gönderi için mevcut kullanıcının rezervasyonlarını sorgula.
      QuerySnapshot snapshots = await FirebaseFirestore.instance
          .collection('postings/${_posting!.id}/bookings')
          .where('userID', isEqualTo: AppConstants.currentUser.id)
          .get();

      // Mevcut kullanıcı tarafından yapılmış bir rezervasyon varsa, kullanıcı yorum gönderebilir.
      _canSubmitReview = snapshots.docs.isNotEmpty;

      // Kullanıcı arayüzünü yenile
      setState(() {});
    } catch (e) {
      print("Yorum yapma yetkisi kontrol edilirken bir hata oluştu.: $e");
      _canSubmitReview = false;
      setState(() {});
    }
  }

  setLatLngOfPropertyAddressForGoogleMap() async {
    final LatLng? position = await CommonFunctions.getLatLngFromAddress(_posting!.address.toString());

    _propertyLatLong = LatLng(position!.latitude, position.longitude);

    //Mülkün konumunu Google Harita'da göster
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _propertyLatLong,
          zoom: 15,
        ),
      ),
    );

    setState(() {});
  }

  loadCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/house.png',
    );

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _posting = widget.posting;

    // Resimleri, sunucuyu, konumu vb. yükleme
    _posting!.getAllImagesFromStorage().whenComplete(() {
      setState(() {});
    });

    _posting!.getHostFromFirestore().whenComplete(() {
      setState(() {});
    });

    setLatLngOfPropertyAddressForGoogleMap();
    loadCustomMarker();

    // İnceleme için rezervasyon iznini kontrol etme
    _checkIfUserCanReview();
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white
              )
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("İlan Detayları",
            style: TextStyle(color: Colors.white)),
        actions: [
          (_posting!.host!.id != AppConstants.currentUser.id) ? //eğer kendi gönderisiyse kaydedemez.
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              AppConstants.currentUser.addSavedPosting(_posting!);

              CommonFunctions.showSnackBar(context, "Favori listenize eklendi.");
            },
          ) : Container(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // Resim karuseli
            AspectRatio(
              aspectRatio: 3 / 2,
              child: PageView.builder(
                itemCount: _posting!.displayImages!.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                      image: _posting!.displayImages![index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            // Posting Name
            Padding(
              padding: const EdgeInsets.all(16),
              child: AutoSizeText(
                _posting!.name!,
                textAlign: TextAlign.justify,
                maxFontSize: 26,
                minFontSize: 13,
                maxLines: 3,
              ),
            ),

            // Description Card
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _posting!.description!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.justify,
              ),
            ),

            // Info Tiles
            _sectionCard(
              title: "Detaylar",
              child: Column(
                children: [
                  PostingInfoTile(
                    iconData: Icons.home,
                    category: _posting!.type!,
                    categoryInfo: '${_posting!.getNumGuests()} guests',
                  ),
                  PostingInfoTile(
                    iconData: Icons.hotel,
                    category: "Yatak",
                    categoryInfo: _posting!.getBedroomText(),
                  ),
                  PostingInfoTile(
                    iconData: Icons.wc,
                    category: "Banyo",
                    categoryInfo: _posting!.getBathroomText(),
                  ),
                ],
              ),
            ),

            // Amenities
            _sectionCard(
              title: "Olanaklar",
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _posting!.amenities!.map((amenity) {
                  return Chip(
                    label: Text(
                      amenity,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ),

            // Location
            _sectionCard(
              title: "Konum",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _posting!.getFullAddress(),
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 10),

                  //Google Map
                  SizedBox(
                    height: 201,
                    child: ClipRRect( //kenarlık eklemek  için
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        mapType: MapType.hybrid,
                        initialCameraPosition: CameraPosition(
                            target: _propertyLatLong,
                            zoom: 15
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("Ev"),
                            position: _propertyLatLong,
                            icon: customIcon ?? BitmapDescriptor.defaultMarker, // fallback if null
                            infoWindow: InfoWindow(
                              title: "Mülk",
                              snippet: _posting!.address,
                            ),
                          ),
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reviews
            _sectionCard(
              title: "Yorumlar",
              child: Column(
                children: [
                  _canSubmitReview ?
                  ReviewFormUi(posting: _posting,)
                      : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Yorum yapabilmek için önce bu ilanı rezerve etmiş olmanız gerekir.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 10),

                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('postings/${_posting!.id}/reviews')
                        .snapshots(),
                    builder: (context, snapshots) {
                      if (snapshots.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshots.data!.docs.length,
                        itemBuilder: (context, index) {
                          Review currentReview = Review();
                          currentReview.getReviewInfoFromFirestore(snapshots.data!.docs[index]);

                          //display reviews using ui design
                          return ReviewDesignTileUi(review: currentReview);
                        },
                      );
                    },
                  ),

                ],
              ),
            ),

            // Host Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: GestureDetector(
                onTap: () {
                  if(_canSubmitReview) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ViewProfilePage(contact: _posting!.host!),
                      ),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // keep content centered
                  children: [
                    Text(
                      "Ev sahibi:",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _posting!.host!.displayImage,
                    ),
                
                    const SizedBox(height: 8),
                    Text(
                      _posting!.host!.getFullName(),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "💵 TL${_posting!.price}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "/ gece",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              //"Şimdi Rezervasyon Yap" düğmesi yalnızca ev sahibi olmayan kullanıcılar için etkinleştirildi
              (_posting!.host!.id != AppConstants.currentUser.id)
                  ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => BookPostingPage(posting: _posting),
                    ),
                  );
                },
                child: const Text(
                  "Şimdi Rezervasyon Yap",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              )
                  : Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "İlanınıza rezervasyon yapamazsınız.",
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
