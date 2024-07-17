import 'package:flutter/material.dart';

import '../../../data/model/place_list_model.dart';

class PlaceItem extends StatefulWidget {
  final PlaceListModel place;
  final Function(bool) onSwitchChanged;

  const PlaceItem(
      {Key? key, required this.place, required this.onSwitchChanged})
      : super(key: key);

  @override
  PlaceItemState createState() => PlaceItemState();
}

class PlaceItemState extends State<PlaceItem> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.place.isEntryMode! ? Icons.input : Icons.output,
                color: widget.place.isEntryMode! ? Colors.blue : Colors.orange,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.alarmName!,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: widget.place.isEntryMode!
                            ? Colors.blue
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                " ${widget.place.alarmRadius!.toStringAsFixed(0)} m",
                style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container()),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    widget.onSwitchChanged(value);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
