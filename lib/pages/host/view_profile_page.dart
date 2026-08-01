import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/review_form_ui.dart';
import 'package:otel_ve_emlak_kiralama/widgets/review_design_tile_ui.dart';

import '../../constants/app_constants.dart';
import '../../models/review_objects.dart';
import '../../models/user_objects.dart';


class ViewProfilePage extends StatefulWidget {
  static final String routeName = '/viewProfilePageRoute';

  final Contact? contact;

  const ViewProfilePage({super.key, this.contact,});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  Contact? _contact;
  UserModel? _user;

  @override
  void initState() {
    super.initState();

    if(widget.contact!.id == AppConstants.currentUser.id){
      _user = AppConstants.currentUser;
    } else {
      _user = widget.contact!.createUserFromContact();
      _user!.getUserInfoFromFirestore().whenComplete(() {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profili Görüntüle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 50, 35, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      'Merhaba, benim adım  ${_user!.firstName}',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: MediaQuery.of(context).size.width / 9.5,
                    child: CircleAvatar(
                      backgroundImage: _user!.displayImage,
                      radius: MediaQuery.of(context).size.width / 10,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Hakkımda',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AutoSizeText(
                  _user!.bio!,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Konum',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.home),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          'Şurada yaşıyor: ${_user!.city}, ${_user!.country}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Yorumlar:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: ReviewFormUi(user: _user!,),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users/${_user!.id}/reviews')
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

                      return ReviewDesignTileUi(review: currentReview);
                    },
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}