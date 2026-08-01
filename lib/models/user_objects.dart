import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/messaging_objects.dart';
import 'package:otel_ve_emlak_kiralama/models/posting_objects.dart';

class Contact {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  MemoryImage? displayImage;

  Contact({this.id = "", this.firstName = "", this.lastName ="", this.displayImage});

  String getFullName() {
    return fullName = firstName! + " " + lastName! ;
  }

  getContactInfoFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(id).get();
    firstName = snapshot['firstName'] ?? "";
    lastName = snapshot['lastName'] ?? "";
  }

  Future<MemoryImage> getImageFromStorage() async {
    if(displayImage != null){return displayImage!;}

    final String imagePath = "userImages/$id/profile_pic.jpg";
    final imageData = await FirebaseStorage.instance.ref().child(imagePath).getData();
    displayImage = MemoryImage(imageData!);

    return displayImage!;
  }

  UserModel createUserFromContact() {
    return UserModel(
      id: id!,
      firstName: firstName!,
      lastName: lastName!,
      displayImage: displayImage!,
    );
  }
}


class UserModel extends Contact{
  DocumentSnapshot? snapshot;
  String? email;
  String? bio ;
  String? city ;
  String? country ;
  bool? isHost;
  bool? isCurrentlyHosting;
  String?  password;

  List<Booking>? bookings;
  List<Posting>? savedPostings;
  List<Posting>? myPostings;

  UserModel({
    String id= "",
    String firstName="",
    String lastName="",
    MemoryImage? displayImage,
    this.email ="",
    this.bio="",
    this.city="",
    this.country="",
  }) : super (id: id, firstName: firstName,lastName: lastName, displayImage: displayImage){
    isHost= false;
    isCurrentlyHosting= false;

    bookings = [];
    savedPostings = [];
    myPostings= [];
  }

  addUserToFirestore() async{
    Map<String, dynamic> data= {
      "bio" :bio,
      "city" : city,
      "country" : country,
      "email" : email,
      "firstName" : firstName,
      "isHost" : isHost,
      "lastName" : lastName,
      "myPostingIDs" : [],
      "savedPostingIDs" : [],
      "earnings": 0
    };
    await FirebaseFirestore.instance.doc('users/$id').set(data);
  }

  addImageToFirestore(File imageFile) async{
    Reference reference= FirebaseStorage.instance.ref().child('userImages/$id/profile_pic.jpg');
    await reference.putFile(imageFile).whenComplete(() {});
    displayImage = MemoryImage(imageFile.readAsBytesSync());
  }

  getPersonalInfoFromFirestore() async{
    await getUserInfoFromFirestore();
    await getImageFromStorage();
    await getMyPostingsFromFirestore();
    await getAllBookingsFromFirestore();
    await getSavedPostingsFromFirestore();
  }

  getAllBookingsFromFirestore() async {
    bookings = [];
    QuerySnapshot snapshots = await FirebaseFirestore.instance.collection('users/$id/bookings').get();

    for(var snapshot in snapshots.docs) {
      Booking userBooking = Booking();
      await userBooking.getBookingInfoFromFirestoreFromUser(createContactFromUser(), snapshot);
      bookings!.add(userBooking);
    }
  }

  getUserInfoFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(id).get();
    this.snapshot=snapshot;
    firstName = snapshot['firstName']  ?? "";
    lastName = snapshot['lastName']  ?? "";
    email = snapshot['email']  ?? "";
    bio = snapshot['bio']  ?? "";
    city = snapshot['city']  ?? "";
    country = snapshot['country']  ?? "";
    isHost = snapshot['isHost']  ?? false;
  }

  Future<MemoryImage> getImageFromStorage() async {
    if(displayImage != null) {
      return displayImage!;
    }
    final  String imagePath= "userImages/$id/profile_pic.jpg";
    final imageData = await FirebaseStorage.instance.ref(imagePath).getData();
    displayImage= MemoryImage(imageData!);

    return displayImage!;

  }

  getMyPostingsFromFirestore() async {
    // Veriyi harita olarak al
    Map<String, dynamic> data = snapshot!.data() as Map<String, dynamic>;

    // Eğer myPostingIDs yoksa boş liste döndür, böylece hata vermez
    List<String> myPostingIDs = List<String>.from(data['myPostingIDs'] ?? []);

    myPostings = []; // Listeyi temizle ki üst üste binmesin
    for(String postingID in myPostingIDs){
      Posting eachPost = Posting(id: postingID);
      await eachPost.getPostingInfoFromFirestore();
      await eachPost.getAllBookingsFromFirestore();
      await eachPost.getAllImagesFromStorage();
      myPostings!.add(eachPost);
    }
  }

  becomeHost() async{
    isHost=true;
    Map<String,dynamic> data= {
      'isHost' : true,
    };
    await FirebaseFirestore.instance.doc('users/$id').update(data);
    changeCurrentlyHosting(true);
  }

  changeCurrentlyHosting(bool isHosting){
    isCurrentlyHosting = isHosting;
  }

  Contact createContactFromUser() {
    return Contact(
      id: id,
      firstName: firstName,
      lastName: lastName,
      displayImage: displayImage,
    );
  }

  addPostingToMyPostings(Posting posting) async {
    myPostings!.add(posting);

    List<String> myPostingIDs = [];
    myPostings!.forEach((posting) { //sunucu tarafından önceden yüklenmiş birden fazla gönderi olacağından for each
      myPostingIDs.add(posting.id!);
    });

    await FirebaseFirestore.instance.doc('users/$id').update({
      'myPostingIDs': myPostingIDs,
    });
  }

  addBookingToFirestore(Booking booking, int totalPriceForAllNights, hostID) async {
    //Mevcut kullanıcı (misafir) kaydına rezervasyon ekle
    Map<String, dynamic> data = {
      'dates': booking.dates,
      'postingID': booking.posting!.id!,
    };
    await FirebaseFirestore.instance.doc('users/$id/bookings/${booking.id}').set(data);

    //Ev Sahibi Kazancını Güncelle
    String earningsOld = "";
    await FirebaseFirestore.instance.collection("users").doc(hostID).get().then((dataSnap)
    {
      earningsOld = dataSnap["earnings"].toString();
    });
    await FirebaseFirestore.instance.collection("users").doc(hostID).update(
        {
          "earnings": totalPriceForAllNights + int.parse(earningsOld),
        });

    bookings!.add(booking);
    await initNewBookingConversation(booking);
    //misafir ve ev sahibi arasındaki konuşmayı biz başlatıyoruz.
  }

  initNewBookingConversation(Booking booking) async {
    Conversation conversation = Conversation();
    await conversation.addConversationToFirestore(booking.posting!.host!);

    String text = "[Yeni Rezervasyon] Selam! Buradan mesaj gönder.";
    await conversation.addMessageToFirestore(text);
  }

  List<Booking> getUpcomingTrips() {
    List<Booking> upcomingTrips = [];

    bookings!.forEach((booking) {
      if(booking.dates!.last.compareTo(DateTime.now()) > 0) {
        upcomingTrips.add(booking);
      }
    });

    return upcomingTrips;
  }

  List<Booking> getPreviousTrips() {
    List<Booking> previousTrips = [];

    bookings!.forEach((booking) {
      if(booking.dates!.last.compareTo(DateTime.now()) <= 0){
        previousTrips.add(booking);
      }
    });

    return previousTrips;
  }

  List<DateTime> getAllBookedDates() {
    List<DateTime> allBookedDates = [];

    myPostings!.forEach((posting) {
      posting.bookings!.forEach((booking) {
        allBookedDates.addAll(booking.dates!);
      });
    });

    return allBookedDates;
  }

  addSavedPosting(Posting posting) async {
    for(var savedPosting in savedPostings!){
      if(savedPosting.id == posting.id){
        return;
      }
    }
    savedPostings!.add(posting);

    List<String> savedPostingIDs = [];

    savedPostings!.forEach((savedPosting) {
      savedPostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.doc('users/$id').update({
      'savedPostingIDs': savedPostingIDs,
    });
  }

  removeSavedPosting(Posting posting) async {
    for(int i = 0; i < savedPostings!.length; i++){
      if(savedPostings![i].id == posting.id){
        savedPostings!.removeAt(i);
        break;
      }
    }

    List<String> savedPostingIDs = [];
    savedPostings!.forEach((savedPosting) {
      savedPostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.doc('users/$id').update({
      'savedPostingIDs': savedPostingIDs,
    });
  }

  getSavedPostingsFromFirestore() async {
    // snapshot null ise veya data gelmemişse işlem yapma
    if (snapshot == null || snapshot!.data() == null) return;

    Map<String, dynamic> data = snapshot!.data() as Map<String, dynamic>;

    // snapshot!['savedPostingIDs'] yerine data['savedPostingIDs'] kullanmak daha güvenlidir
    List<String> savedPostingIDs = List<String>.from(data['savedPostingIDs'] ?? []);

    savedPostings = [];
    for(String postingID in savedPostingIDs) {
      // Eğer postingID boş bir string ise hata almamak için kontrol ekle
      if(postingID.trim().isEmpty) continue;

      Posting newPosting = Posting(id: postingID);
      await newPosting.getPostingInfoFromFirestore();
      await newPosting.getFirstImageFromStorage();
      savedPostings!.add(newPosting);
    }
  }

  postNewReview(String text, double rating) async {
    Map<String,dynamic> data = {
      'dateTime': DateTime.now(),
      'name': AppConstants.currentUser!.getFullName(),
      'rating': rating,
      'text': text,
      'userID': AppConstants.currentUser!.id,
    };
    await FirebaseFirestore.instance.collection('users/$id/reviews').add(data);
  }

  updateUserInFirestore() async {
    Map<String, dynamic> userDataMap = {
      "bio" : bio,
      "city" : city,
      "country": country,
      "firstName": firstName,
      "lastName": lastName,
    };
    await FirebaseFirestore.instance.doc('users/$id').update(userDataMap);
  }

}