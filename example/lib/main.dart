import 'package:flutter/material.dart';
import 'package:location_picker/location_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

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
        locale: "en",
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
