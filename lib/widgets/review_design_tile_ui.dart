import 'package:auto_size_text/auto_size_text.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';

import '../models/review_objects.dart';


class ReviewDesignTileUi extends StatefulWidget {
  final Review? review;

  const ReviewDesignTileUi({super.key, this.review,});

  @override
  State<ReviewDesignTileUi> createState() => _ReviewDesignTileUiState();
}

class _ReviewDesignTileUiState extends State<ReviewDesignTileUi> {
  Review? _review;
  bool _isExpanded = false; // track whether text is expanded

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getReview();
  }

  getReview() {
    _review = widget.review;
    _review!.contact!.getImageFromStorage().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Avatar
        InkResponse(
          onTap: () {},
          child: CircleAvatar(
            backgroundImage: _review!.contact!.displayImage,
            radius: MediaQuery.of(context).size.width / 15,
          ),
        ),

        const SizedBox(width: 8),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                _review!.contact!.getFullName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              RatingBar.readOnly(
                size: 18.0,
                maxRating: 5,
                initialRating: _review!.rating!,
                filledIcon: Icons.star,
                emptyIcon: Icons.star_border,
                filledColor: Colors.green,
              ),

              // Review Text with "See more"
              LayoutBuilder(builder: (context, constraints) {
                final text = _review!.text!;
                final textSpan = TextSpan(text: text);
                final textPainter = TextPainter(
                  text: textSpan,
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final isOverflowing = textPainter.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: ConstrainedBox(
                        constraints: _isExpanded
                            ? const BoxConstraints()
                            : BoxConstraints(maxHeight: textPainter.preferredLineHeight * 2),
                        child: Text(
                          text,
                          maxLines: _isExpanded ? null : 2,
                          overflow:
                          _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    if (isOverflowing)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ?
                          'Daha az göster' : 'Daha fazla göster',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
