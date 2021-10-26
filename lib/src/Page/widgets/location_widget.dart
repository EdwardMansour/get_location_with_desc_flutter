import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  final String? text;
  const LocationWidget({
    Key? key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              //color: Colors.white,
              elevation: 0,
              child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    text!,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ))),
        ),
      ],
    );
  }
}
