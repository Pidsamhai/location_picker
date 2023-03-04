import 'package:flutter/widgets.dart';

mixin OnReadyMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onReady();
    });
  }

  void onReady() {}
}
