import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../models/posting_objects.dart';


class GridWidgetUi extends StatefulWidget {
  Booking? booking;
  GridWidgetUi({super.key, this.booking,});

  @override
  State<GridWidgetUi> createState() => _GridWidgetUiState();
}

class _GridWidgetUiState extends State<GridWidgetUi> {
  Booking? _booking;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _booking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _booking!.posting!.displayImages!.first,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),

        AutoSizeText(
          _booking!.posting!.name!,
          maxLines: 2,
          maxFontSize: 19,
        ),
        AutoSizeText(
          '${_booking!.posting!.city}, ${_booking!.posting!.country}',
          maxLines: 2,
          maxFontSize: 15,
        ),
        Text(
          'TL 💵 ${_booking!.posting!.price} / gece',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        Text(
          '${_booking!.getFirstDate()}  ile  ${_booking!.getLastDate()}',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),

      ],
    );
  }
}
