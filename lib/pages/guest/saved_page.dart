import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/common/common_functions.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/models/posting_objects.dart';
import 'package:otel_ve_emlak_kiralama/pages/guest/view_posting_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/posting_grid_tile.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
      child: GridView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: AppConstants.currentUser.savedPostings!.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          Posting currentPosting = AppConstants.currentUser.savedPostings![index];
          return Stack(children: [
            InkResponse(
              enableFeedback: true,
              child: PostingGridTile(posting: currentPosting,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewPostingPage(posting: currentPosting),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  width: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: () {
                      AppConstants.currentUser.removeSavedPosting(currentPosting).whenComplete((){
                        setState(() {

                        });

                        CommonFunctions.showSnackBar(context, "Favoriler listenizden silindi.");
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
