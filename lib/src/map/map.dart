import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    required this.lat,
    required this.lng,
    this.onTapFunction,
    required this.mapController,
    required this.markers,
    this.apiKey,
  }) : super(key: key);
  final List<Marker> markers;
  final double lat;
  final double lng;
  final MapController mapController;
  final String? apiKey;
  final Function? onTapFunction;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
          onTap: (tapPosition, point) {
            if (widget.onTapFunction != null) {
              widget.onTapFunction!(tapPosition, point);
            }
          },
          center: LatLng(widget.lat, widget.lng),
          zoom: 13,
          maxZoom: 18),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: widget.markers,
        ),
      ],
    );
  }
}
