import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

///! Services
class NominatimService {
  Future<Map> getAddressLatLng({String? lat, String? long}) async {
    var client = http.Client();
    const String _baseUrl = 'nominatim.openstreetmap.org';
    late Uri uri = Uri.https(_baseUrl, '/reverse', {
      'lat': lat,
      'lon': long,
      'format': 'json',
      'addressdetails': '1',
    });
    var response = await client.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    var ad = jsonDecode(response.body);
    Map share = {};

    share = {
      'lat': ad['lat'],
      'lng': ad['lon'],
      'description': ad['display_name'],
      'state': ad['address']['state'] ?? "na",
      'city': ad['address']['city'] ?? "na",
      'suburb': ad['address']['suburb'] ?? "na",
      'neighbourhood': ad['address']['neighbourhood'] ?? "na",
      'road': ad['address']['road'] ?? "na",
    };

    return share;
  }

  //! name search
  Future<List<Map>> getAddressNameSearch(String address) async {
    var client = http.Client();
    const String _baseUrl = 'nominatim.openstreetmap.org';
    late Uri uri = Uri.https(_baseUrl, '/search', {
      'q': address.replaceAll(RegExp(' '), '+'),
      'format': 'json',
      'addressdetails': '1',
    });
    var response = await client.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    List addresses = jsonDecode(response.body);
    List<Map> share = [];
    for (Map ad in addresses) {
      share.add({
        'lat': ad['lat'],
        'lng': ad['lon'],
        'description': ad['display_name'],
        'state': ad['address']['state'] ?? "na",
        'city': ad['address']['city'] ?? "na",
        'suburb': ad['address']['suburb'] ?? "na",
        'neighbourhood': ad['address']['neighbourhood'] ?? "na",
        'road': ad['address']['road'] ?? "na",
      });
    }
    return share;
  }
}
