import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/constants/app_constants.dart';
import 'package:otel_ve_emlak_kiralama/pages/host/create_update_posting_page.dart';
import 'package:otel_ve_emlak_kiralama/widgets/create_posting_list_tile_button.dart';
import 'package:otel_ve_emlak_kiralama/widgets/show_my_posting_list_tile.dart';

class MyPostingsPage extends StatefulWidget {
  const MyPostingsPage({super.key});

  @override
  State<MyPostingsPage> createState() => _MyPostingsPageState();
}

class _MyPostingsPageState extends State<MyPostingsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 23),
      child: ListView.builder(
        itemCount: AppConstants.currentUser.myPostings!.length + 1,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(25,0,25,25),
            child: InkResponse(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateUpdatePostingPage(
                    posting: (index == AppConstants.currentUser.myPostings!.length)
                        ? null
                        : AppConstants.currentUser.myPostings![index]
                )));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: index == AppConstants.currentUser.myPostings!.length
                    ? CreatePostingListTileButton()
                    : ShowMyPostingListTile(posting: AppConstants.currentUser.myPostings![index]),
              ),
            ),
          );
        },

      ),
    );
  }
}
