import 'package:flutter/material.dart';

class FacilitiesWidget extends StatefulWidget {
  final String type;
  final int startValue;
  final Function decreaseValue;
  final Function increaseValue;

  const FacilitiesWidget({
    super.key,
    required this.type,
    required this.startValue,
    required this.decreaseValue,
    required this.increaseValue,
  });

  @override
  State<FacilitiesWidget> createState() => _FacilitiesWidgetState();
}

class _FacilitiesWidgetState extends State<FacilitiesWidget> {
  int? _value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _value = widget.startValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[

          Text(
            widget.type,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),

          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  widget.decreaseValue();
                  _value = (_value! - 1).clamp(0, 9999); //böyle yaptığımız için negatif bir değer almayacağız.
                  setState(() {});
                },
              ),
              Text(
                _value.toString(),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  widget.increaseValue();
                  _value = _value! + 1;
                  setState(() {});
                },
              ),
            ],
          ),

        ],
      ),
    );
  }
}
