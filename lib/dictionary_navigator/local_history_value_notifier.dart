import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalHistoryValueNotifier<T> extends ValueNotifier<T> {
  LocalHistoryValueNotifier({required this.modalRoute, required T initialValue})
      : super(initialValue);

  final ModalRoute<dynamic> modalRoute;

  @override
  set value(T newValue) {
    if (value == newValue) {
      return;
    }
    // Create locally scoped variable so onRemove always resets to the correct
    // value.
    final T returnValue = value;
    super.value = newValue;
    modalRoute.addLocalHistoryEntry(
      LocalHistoryEntry(
        onRemove: () {
          super.value = returnValue;
        },
      ),
    );
  }
}
