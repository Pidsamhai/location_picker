// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_geo_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReverseGeoCode _$ReverseGeoCodeFromJson(Map<String, dynamic> json) =>
    ReverseGeoCode(
      json['geocode'] as String,
      json['country'] as String,
      json['province'] as String,
      json['district'] as String,
      json['subdistrict'] as String,
      json['postcode'] as String,
      (json['elevation'] as num).toDouble(),
    );
