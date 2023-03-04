# Flutter Location Picker

using [Longdo Map](https://map.longdo.com/console/) reverse geocode

only Thailand

![Art](/art/art.gif)

```dart
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Picker"),
      ),
      body: LocationPickerWidget(
        // https://map.longdo.com/console/
        apiKey: "API-KEY",
        searchIcon: const Icon(Icons.search_rounded),
        customCoordinate: true,
        positionIcon: const Icon(
          Icons.add,
          color: Colors.pink,
        ),
        locale: "en", // en, th
        onSelected: (reverseGeoCode, latLng) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text("Location"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Location: $reverseGeoCode"),
                    const SizedBox.square(dimension: 8),
                    Text("Coordinate: ${latLng.latitude},${latLng.longitude}")
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text("OK"),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
```

# Permission

### Ios Info.plist

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>App need to access to your location</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>App need to access to your location</string>
```

### Android Info.plist

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET"/>
```

### Depencies

```yml
dio: 
dio_logging_interceptor:
flutter_map:
freezed_annotation: 
geolocator: 
latlong2: 
rxdart: 
```
