import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../model/longdo/search/reverse_geo_code.dart';
import '../model/longdo/search/search_location.dart';
import '../repository/longdo_repository.dart';
import 'custom_coordinate_dialog.dart';
import 'package:rxdart/rxdart.dart' as rx;

import 'spacer_box.dart';

class LocationPickerWidget extends StatefulWidget {
  final String apiKey;
  final Widget? positionIcon;
  final Widget? myPositionIcon;
  final String searchLabel;
  final Widget? searchIcon;
  final String locale;
  final Duration searchDebounceDuration;
  final bool customCoordinate;
  final bool log;
  final Function(ReverseGeoCode reverseGeoCode, LatLng latLng)? onSelected;
  final LatLng? defaultLocation;
  final bool loadMyPosition;
  const LocationPickerWidget({
    Key? key,
    required this.apiKey,
    this.positionIcon,
    this.myPositionIcon,
    this.searchLabel = "Search",
    this.searchIcon,
    this.onSelected,
    this.locale = "en",
    this.searchDebounceDuration = const Duration(seconds: 1),
    this.customCoordinate = false,
    this.log = true,
    this.defaultLocation,
    this.loadMyPosition = true,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget>
    with TickerProviderStateMixin {
  late final animController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animController.repeat(reverse: true);
      initListener();
    });
  }

  void notifyListeners() {
    if (mounted) {
      setState(() => {});
    }
  }

  final mapController = MapController();
  final searchKeywordController = TextEditingController();
  late final _longdoRepository = LongdoRepository(
    widget.apiKey,
    widget.locale,
    widget.log,
  );

  List<SearchLocation> searchResultList = [];
  final rx.PublishSubject<String> searchKeyword = rx.PublishSubject<String>();
  StreamSubscription<List<SearchLocation>>? _searchResult$;
  late final Stream<List<SearchLocation>> searchResult = searchKeyword
      .debounce((_) => rx.TimerStream(true, widget.searchDebounceDuration))
      .map((event) {
    isLoadSearch = true;
    return event;
  }).asyncMap<List<SearchLocation>>(
    (v) => v.isNotEmpty ? _longdoRepository.search(v) : Future.value([]),
  );
  ReverseGeoCode? _reverseGeoCode;
  ReverseGeoCode? get reverseGeoCode => _reverseGeoCode;
  set reverseGeoCode(ReverseGeoCode? n) {
    _reverseGeoCode = n;
    notifyListeners();
  }

  // For Skip Search change when set selected search result
  bool skipKeywordChange = false;

  // ReverseGeo Load State
  bool _isLoadReverse = false;
  bool get isLoadReverse => _isLoadReverse;
  set isLoadReverse(bool n) {
    _isLoadReverse = n;
    notifyListeners();
  }

// Search Load State
  bool _isLoadSearch = false;
  bool get isLoadSearch => _isLoadSearch;
  set isLoadSearch(bool n) {
    _isLoadSearch = n;
    notifyListeners();
  }

  final rx.BehaviorSubject<LatLng> _currentPosition = rx.BehaviorSubject();

  late final Stream<ReverseGeoCode?> _reverseGeoCodeResult = _currentPosition
      .debounce((_) => rx.TimerStream(true, const Duration(seconds: 1)))
      .map((event) {
    isLoadReverse = true;
    return event;
  }).asyncMap(
    (event) => _longdoRepository.reverseGeoCode(
      event.latitude,
      event.longitude,
    ),
  );

  late StreamSubscription<ReverseGeoCode?>? _reverseGeoCodeResult$;

  moveToCurrentCenter() async {
    _currentPosition.sink.add(mapController.center);
  }

  void initListener() {
    _searchResult$ = searchResult.listen(
      (event) {
        searchResultList.clear();
        searchResultList.addAll(event);
        isLoadSearch = false;
      },
      onDone: () => isLoadSearch = false,
      onError: (v) => isLoadSearch = false,
    );

    _reverseGeoCodeResult$ = _reverseGeoCodeResult.listen(
      (event) {
        reverseGeoCode = event;
        isLoadReverse = false;
      },
      onDone: () => isLoadReverse = false,
      onError: (e) => isLoadReverse = false,
    );

    if (widget.defaultLocation == null) {
      if (widget.loadMyPosition) {
        moveToMyPosition();
      }
      return;
    }

    moveToDefaultLocation();
  }

  moveToDefaultLocation() {
    mapController.move(
      widget.defaultLocation!,
      15,
    );
    _currentPosition.sink.add(widget.defaultLocation!);
  }

  showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

  // ignore: use_build_context_synchronously
  moveToMyPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showError(
        'Location services are disabled.',
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showError(
          'Location permissions are denied',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showError(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return;
    }

    final point = await Geolocator.getCurrentPosition();
    moveByLatLong(LatLng(point.latitude, point.longitude));
  }

  moveByLatLong(LatLng latLng) async {
    mapController.move(
      latLng,
      15,
    );
    _currentPosition.sink.add(latLng);
  }

  movetoSelectedLocation(SearchLocation location) {
    searchResultList.clear();
    notifyListeners();
    _currentPosition.sink.add(LatLng(location.lat, location.lon));
    mapController.move(
      LatLng(location.lat, location.lon),
      15,
    );
  }

  customMoveLocation() async {
    final result = await showDialog<LatLng>(
      context: context,
      builder: (_) => const CustomCoordinateDialog(),
    );
    if (result != null) {
      moveByLatLong(result);
    }
  }

  @override
  void dispose() {
    animController.dispose();
    _currentPosition.close();
    _reverseGeoCodeResult$?.cancel();
    searchKeyword.close();
    _searchResult$?.cancel();
    searchKeywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              interactiveFlags: InteractiveFlag.all,
              center: widget.defaultLocation,
              onPointerUp: (event, point) {
                animController.repeat(reverse: true);
                moveToCurrentCenter();
              },
              onPointerDown: (event, point) {
                animController.stop();
                animController.value = 0.05;
                FocusScope.of(context).unfocus();
              },
              zoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "http://ms.longdo.com/mmmap/img.php?zoom={z}&x={x}&y={y}&mode=icons&key=${widget.apiKey}&proj=epsg3857&HD=1",
              ),
            ],
          ),
          ScaleTransition(
            scale: Tween(begin: 0.75, end: 1.5).animate(
              CurvedAnimation(
                parent: animController,
                curve: Curves.elasticOut,
              ),
            ),
            child: widget.positionIcon ??
                const Icon(
                  Icons.place,
                  size: 24,
                  color: Colors.red,
                ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchKeywordController,
                      onChanged: (v) {
                        if (!skipKeywordChange) {
                          searchKeyword.sink.add(v);
                        }
                        skipKeywordChange = false;
                        return;
                      },
                      decoration: InputDecoration(
                        hintText: widget.searchLabel,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: widget.searchIcon,
                        suffixIcon: searchKeywordController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchKeywordController.clear();
                                  searchKeyword.sink.add("");
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),
                    if (isLoadSearch) ...[
                      const LinearProgressIndicator(),
                    ],
                    buildSearchResultList()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.customCoordinate) ...[
              FloatingActionButton.small(
                heroTag: const Key("location-picker-custom-move"),
                onPressed: customMoveLocation,
                child: const Icon(Icons.edit_location_rounded),
              ),
            ],
            FloatingActionButton.small(
              heroTag: const Key("location-picker-my-location"),
              onPressed: moveToMyPosition,
              child: const Icon(Icons.my_location_outlined),
            ),
            Card(
              surfaceTintColor: Colors.white,
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 54,
                width: double.maxFinite,
                child: Row(
                  children: [
                    if (isLoadReverse) ...[
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(),
                      ),
                      SpaceBox.s,
                    ],
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        reverseGeoCode?.fullName ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (reverseGeoCode != null)
                      FloatingActionButton.small(
                        heroTag: const Key("location-picker-select-location"),
                        onPressed: () {
                          widget.onSelected?.call(
                            reverseGeoCode!,
                            _currentPosition.value,
                          );
                        },
                        child: const Icon(Icons.navigate_next_rounded),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchResultList() {
    if (searchResultList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: searchResultList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              skipKeywordChange = true;
              searchKeywordController.text = searchResultList[index].name;
              FocusScope.of(context).unfocus();
              movetoSelectedLocation(
                searchResultList[index],
              );
            },
            title: Text(
              searchResultList[index].name,
            ),
          );
        },
      ),
    );
  }
}
