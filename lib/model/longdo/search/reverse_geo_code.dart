import 'package:freezed_annotation/freezed_annotation.dart';

part 'reverse_geo_code.g.dart';

@JsonSerializable(createToJson: false)
class ReverseGeoCode {
  final String geocode;
  final String country;
  final String province;
  final String district;
  final String subdistrict;
  final String postcode;
  final double elevation;
  String get fullName =>
      "${subdistrict.replaceFirst("ต.", "")}, ${district.replaceFirst("อ.", "")}, ${province.replaceFirst("จ.", "")}, $postcode";
  ReverseGeoCode(
    this.geocode,
    this.country,
    this.province,
    this.district,
    this.subdistrict,
    this.postcode,
    this.elevation,
  );

  factory ReverseGeoCode.fromJson(dynamic json) =>
      _$ReverseGeoCodeFromJson(json);

  @override
  String toString() {
    return fullName;
  }
}
