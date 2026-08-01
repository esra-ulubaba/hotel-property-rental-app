import 'package:flutter/material.dart';


class CreatePostingListTileButton extends StatelessWidget {
  const CreatePostingListTileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 12,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Text(
            'Bir Liste Oluşturun',
            style: TextStyle(
              fontSize: 21,
            ),
          ),
        ],
      ),
    );
  }
}
