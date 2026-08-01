import 'package:flutter/material.dart';


class PostingInfoTile extends StatelessWidget {
  final IconData? iconData;
  final String? category;
  final String? categoryInfo;

  const PostingInfoTile({super.key, this.iconData, this.category, this.categoryInfo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData, size: 30, color: Colors.green),
      title: Text(
        category!,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      subtitle: Text(
        categoryInfo!,
        style: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );
  }
}
