import 'package:dio/dio.dart';
// import 'package:dio_logging_interceptor/dio_logging_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../model/longdo/search/reverse_geo_code.dart';
import '../model/longdo/search/search_location.dart';

class LongdoRepository {
  final _client = Dio();
  final String _apiKey;
  final String _locale;

  LongdoRepository(this._apiKey, this._locale, bool log) {
    if (log) {
      _client.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<List<SearchLocation>> search(String keyword) async {
    final result = await _client.get(
      "https://search.longdo.com/mapsearch/json/search",
      queryParameters: {
        "key": _apiKey,
        "keyword": keyword,
        "locale": _locale,
      },
    );
    return (result.data["data"] as List).map(SearchLocation.fromJson).toList();
  }

  Future<ReverseGeoCode> reverseGeoCode(
    double lat,
    double lon,
  ) async {
    final result = await _client
        .get("https://api.longdo.com/map/services/address", queryParameters: {
      "key": _apiKey,
      "lat": lat,
      "lon": lon,
      "locale": _locale,
    });
    return ReverseGeoCode.fromJson(result.data);
  }
}
