// {
//             "type": "khet",
//             "id": "K00670300",
//             "name": "Lom Sak, Phetchabun",
//             "lat": 16.728322595294525,
//             "lon": 101.31142701759461,
//             "icon": "",
//             "tag": [
//                 "district"
//             ],
//             "url": "",
//             "address": "Code: 6703",
//             "tel": "",
//             "contributor": "",
//             "verified": true,
//             "obsoleted": false
//         }
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_location.g.dart';

@JsonSerializable(createToJson: false)
class SearchLocation {
  final String name;
  final double lat;
  final double lon;
  const SearchLocation(
    this.name,
    this.lat,
    this.lon,
  );

  factory SearchLocation.fromJson(dynamic json) =>
      _$SearchLocationFromJson(json);
}
