import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';

import '../../models/posting_objects.dart';
import '../../models/user_objects.dart';


class ReviewFormUi extends StatefulWidget {
  final Posting? posting;
  final UserModel? user;

  const ReviewFormUi({super.key, this.posting, this.user,});

  @override
  State<ReviewFormUi> createState() => _ReviewFormUiState();
}

class _ReviewFormUiState extends State<ReviewFormUi> {
  TextEditingController _controller = new TextEditingController();
  double _rating = 2.0;

  _saveNewReview() {
    if(widget.posting == null) {
      ///review specific host
      widget.user!.postNewReview(_controller.text, _rating).whenComplete((){
        _controller.text = "";
        _rating = 2.5;
        setState(() {});

        CommonFunctions.showSnackBar(context, "Değerlendirmeniz gönderildi.");

        Navigator.pop(context);
      });
    } else {
      //review specific property posting
      widget.posting!.postNewReview(_controller.text, _rating).whenComplete((){
        _controller.text = "";
        _rating = 2.5;
        setState(() {});

        CommonFunctions.showSnackBar(context, "Değerlendirmeniz gönderildi.");

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'buraya yazın...',
                    ),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    controller: _controller,
                    validator: (text){
                      if(text!.isEmpty){
                        return "Lütfen bir metin girin";
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RatingBar(
                            size: 30.0,
                            maxRating: 5,
                            initialRating: _rating,
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            filledColor: Colors.green,
                            onRatingChanged: (rating) {
                              _rating = rating;
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          onPressed: _saveNewReview,
                          color: Colors.black,
                          minWidth: 80,
                          child: const Text(
                            'Gönder',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
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