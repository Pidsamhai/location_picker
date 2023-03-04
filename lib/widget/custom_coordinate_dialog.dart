import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker/widget/spacer_box.dart';

class CustomCoordinateDialog extends StatefulWidget {
  const CustomCoordinateDialog({super.key});

  @override
  State<CustomCoordinateDialog> createState() => _CustomCoordinateDialogState();
}

class _CustomCoordinateDialogState extends State<CustomCoordinateDialog> {
  final latController = TextEditingController();

  final longController = TextEditingController();

  final formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Coordinate"),
      content: Form(
        key: formState,
        autovalidateMode: AutovalidateMode.always,
        onChanged: () => setState(() {}),
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: "lat",
                  hintText: "-90 - 90",
                ),
                validator: (value) {
                  try {
                    final v = double.parse(value ?? "");
                    if (v >= -90 && v <= 90) return null;
                    throw Exception();
                  } catch (e) {
                    return "invalid";
                  }
                },
              ),
            ),
            SpaceBox.s,
            Flexible(
              child: TextFormField(
                controller: longController,
                decoration: const InputDecoration(
                  labelText: "long",
                  hintText: "-180 - 180",
                ),
                validator: (value) {
                  try {
                    final v = double.parse(value ?? "");
                    if (v >= -180 && v <= 180) return null;
                    throw Exception();
                  } catch (e) {
                    return "invalid";
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: formState.currentState?.validate() == true
              ? () => Navigator.of(context).pop(
                    LatLng(
                      double.parse(latController.text),
                      double.parse(longController.text),
                    ),
                  )
              : null,
          child: const Text("OK"),
        ),
      ],
    );
  }
}
