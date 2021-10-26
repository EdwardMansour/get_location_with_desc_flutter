import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../get_location_with_desc_flutter.dart';
import 'widgets/description_files.dart';
import 'widgets/location_widget.dart';

class UserLocationPicker extends StatefulWidget {
  const UserLocationPicker({
    Key? key,
    this.searchHint = 'Search',
    this.awaitingForLocation = "Awaiting for you current location",
    this.customMarkerIcon,
  }) : super(key: key);

  final String searchHint;
  final String awaitingForLocation;

  //
  final Widget? customMarkerIcon;

  @override
  _UserLocationPickerState createState() => _UserLocationPickerState();
}

class _UserLocationPickerState extends State<UserLocationPicker> {
  late Map retorno = {};

  late List _addresses = [];
  final Color _color = Colors.black;
  late final TextEditingController _ctrlSearch = TextEditingController();
  Position? _currentPosition;
  late String _desc = '';
  late bool _isSearching = false;
  late double _lat;
  late double _lng;
  late final MapController _mapController = MapController();

  late List<Marker> _markers = [];

  late LatLng _point = LatLng(0, 0);

  @override
  void dispose() {
    _ctrlSearch.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _markers = [
      Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(0.0, 0.0),
        builder: (ctx) => Container(
          child: widget.customMarkerIcon ??
              const Icon(
                Icons.location_on,
                size: 50.0,
              ),
        ),
      )
    ];
  }

  void _changeAppBar() {
    /*
    --- manage appbar state
  */
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  ///! Get Current Location
  _getCurrentLocation() async {
    /*
    --- Get Current Location 
  */
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getCurrentLocationMarker();
        _getCurrentLocationDescription();
      });
    }).catchError((e) {
      log(e);
    });
  }

  ///! Get Current Location Marker
  _getCurrentLocationMarker() {
    /*
    --- Get Current Location Marker
  */
    setState(() {
      _lat = _currentPosition!.latitude;
      _lng = _currentPosition!.longitude;
      _point = LatLng(_lat, _lng);
      _markers[0] = Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        builder: (ctx) => Container(
            child: widget.customMarkerIcon ??
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50.0,
                )),
      );
    });
  }

  ///! Get Current Location Description
  _getCurrentLocationDescription() async {
    /*
    --- Get Currunt Location Description
  */
    dynamic res = await NominatimService().getAddressLatLng(
        lat: '${_currentPosition!.latitude}',
        long: '${_currentPosition!.longitude}');
    setState(() {
      // _addresses = res;
      _lat = _currentPosition!.latitude;
      _lng = _currentPosition!.longitude;
      _point = LatLng(_lat, _lng);
      retorno = {
        'latlng': _point,
        'state': res['state'],
        'desc':
            "${res['state']}, ${res['city']}, ${res['suburb']}, ${res['neighbourhood']}, ${res['road']}"
      };
      _desc = res['description'];
    });
  }

  ///! App Bar Widget
  _appBarWidget(bool _isResult) {
    /*
    --- App Bar Widget 
  */
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      primary: true,
      title: _textFieldWidgetInAppBar(_isResult),
    );
  }

  ///! AppBar TextField Widget
  _textFieldWidgetInAppBar(bool _isResult) {
    /*
    --- Searching appBar textField widget
  */
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                child: TextFormField(
                    controller: _ctrlSearch,
                    decoration: InputDecoration(
                        hintText: widget.searchHint,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.grey))),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: _color),
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                _isResult == false
                    ? _changeAppBar()
                    : setState(() {
                        _isSearching = true;
                      });
                dynamic res = await NominatimService()
                    .getAddressNameSearch(_ctrlSearch.text);
                setState(() {
                  _addresses = res;
                });
              },
            ),
          ],
        ));
  }

  ///! Map Widget
  Widget _mapWidget(BuildContext context) {
    /*
    --- Widget of the map
  */
    while (_currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MapWidget(
      lat: _lat,
      lng: _lng,
      onTapFunction: (onTapPosition, pointer) async {
        dynamic res = await NominatimService().getAddressLatLng(
            lat: '${pointer!.latitude}', long: '${pointer!.longitude}');
        setState(() {
          _lat = pointer!.latitude;
          _lng = pointer!.longitude;
          _point = LatLng(_lat, _lng);
          retorno = {
            'latlng': _point,
            'state': res['state'],
            'desc':
                "${res['state']}, ${res['city']}, ${res['suburb']}, ${res['neighbourhood']}, ${res['road']}"
          };
          _desc = res['description'];
          _point = LatLng(_lat, _lng);
          _markers[0] = Marker(
            width: 80.0,
            height: 80.0,
            point: _point,
            builder: (ctx) => Container(
                child: widget.customMarkerIcon ??
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50.0,
                    )),
          );
        });
      },
      mapController: _mapController,
      markers: _markers,
    );
  }

  ///! Body Widget
  Widget _bodyWidget(BuildContext context) {
    /*
    --- Widget of the body
  */
    return Stack(
      children: <Widget>[
        _mapWidget(context),
        _isSearching
            ? Container()
            : DescriptionFiles(
                description:
                    _desc != '' ? _desc : 'Awaiting for the description',
              ),
        _isSearching ? searchListingResultWidget() : const Text(''),
      ],
    );
  }

  ///! Search listing result
  Widget searchListingResultWidget() {
    /*
    --- return the list of the search result
  */
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
      color: Colors.transparent,
      child: ListView.builder(
        itemCount: _addresses.length,
        itemBuilder: (BuildContext ctx, int index) {
          return GestureDetector(
            child: LocationWidget(text: _addresses[index]['description']),
            onTap: () {
              _mapController.move(
                  LatLng(double.parse(_addresses[index]['lat']),
                      double.parse(_addresses[index]['lng'])),
                  19);

              setState(() {
                _desc = _addresses[index]['description'];
                _isSearching = false;
                _lat = double.parse(_addresses[index]['lat']);
                _lng = double.parse(_addresses[index]['lng']);
                retorno = {
                  'latlng': LatLng(_lat, _lng),
                  'state': _addresses[index]['state'],
                  'desc':
                      "${_addresses[index]['state']}, ${_addresses[index]['city']}, ${_addresses[index]['suburb']}, ${_addresses[index]['neighbourhood']}, ${_addresses[index]['road']}"
                };
                _markers[0] = Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(double.parse(_addresses[index]['lat']),
                      double.parse(_addresses[index]['lng'])),
                  builder: (ctx) => Container(
                      child: widget.customMarkerIcon ??
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50.0,
                          )),
                );
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBarWidget(_isSearching),
      body: _bodyWidget(context),
    );
  }
}
